module "project" {
  source            = "terraform-google-modules/project-factory/google"
  version           = "18.0.0"
  name              = var.name
  random_project_id = true
  org_id            = var.organisation
  billing_account   = var.billing_account

  /* Services */
  activate_apis               = var.services
  disable_services_on_destroy = false
  disable_dependent_services  = false

  labels = {
    env = var.name
  }
}

module "network_security" {
	source = "../network-security"
	project_id = module.project.project_id
	allowed_networks = var.allowed_networks
}

module "gke" {
	source = "../gke"
	name = var.name
	project_id = module.project.project_id
	docker_gar = data.terraform_remote_state.management.outputs.docker_gar
	region = var.region
	allowed_networks = var.allowed_networks
}

module "keycloak" {
	source = "../keycloak"
	project_id = module.project.project_id
	name = "keycloak"
	host = "keycloak.${var.name}.roamtech.whitemire-technologies.com"
	dns_managed_zone_project_id = var.management_project_id
	dns_managed_zone_name = "root"
	depends_on = [module.gke, helm_release.environment_core]
}

module "external_secrets" {
	source = "../external-secrets"
	project_id = module.project.project_id
}

resource "helm_release" "environment_core" {
  name       = "environment-core"
  chart      = "${path.module}/../../../helm/charts/environment-core"

	# 15 Minute timeout, can take longer on intial cluster setup.
	timeout = 900

	values = [yamlencode({
		projectId = module.project.project_id
		region = var.region
		name = module.gke.name
	})]

	depends_on = [module.external_secrets]
}

module "application_service" {
	for_each = var.application_services
	source = "../application-service"
	project_id = module.project.project_id
	name = each.key
	tag = each.value.tag
	/* TODO: Use management outputs */
	gar = "${var.region}-docker.pkg.dev/${var.management_project_id}/docker"
	ingress = (each.value.ingress) ? {
    host = "${each.key}.${var.name}.roamtech.whitemire-technologies.com"
		dns_managed_zone = {
			project_id = var.management_project_id
			name = "root"
		}
	} : null
}

