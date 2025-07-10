module "keycloak" {
	source = "../../keycloak"
	project_id = local.project_id
	name = "keycloak"
	host = "keycloak.${var.name}.roamtech.whitemire-technologies.com"
	dns_managed_zone_project_id = var.management_project_id
	dns_managed_zone_name = "root"
	depends_on = [helm_release.environment_core]
}

module "external_secrets" {
	source = "../../external-secrets"
	project_id = local.project_id
}

resource "helm_release" "environment_core" {
  name       = "environment-core"
  chart      = "${path.module}/../../../../helm/charts/environment-core"

	# 15 Minute timeout, can take longer on intial cluster setup.
	timeout = 900

	values = [yamlencode({
		projectId = local.project_id
		region = var.region
		name = data.terraform_remote_state.infra.outputs.gke_cluster.name
	})]

	depends_on = [module.external_secrets]
}

module "application_service" {
	for_each = var.application_services
	source = "../../application-service"
	project_id = local.project_id
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
	port = each.value.port
}

resource "helm_release" "kafka" {
  name       = "kafka"
  chart      = "kafka"
	repository = "https://helm-charts.itboon.top/kafka"
	namespace = "kafka"

	create_namespace = true
	# 15 Minute timeout, can take longer on intial cluster setup.
	timeout = 900
}

module "redis" {
	source = "../../redis"
	project_id = local.project_id
	users = ["paykit-core"]
	depends_on = [helm_release.environment_core]
}

