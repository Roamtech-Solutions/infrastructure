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
	source = "./modules/network-security"
	project_id = module.project.project_id
	allowed_networks = var.allowed_networks
}

module "management" {
	/* Only for the management environment */
	count = (var.name == "management") ? 1 : 0
	source = "./modules/management"
	project_id = module.project.project_id
	region = var.regions[0]
}

module "gke" {
	/* Management doesn't get a cluster */
	count = (var.name == "management") ? 0 : 1
	source = "./modules/gke"
	name = var.name
	project_id = module.project.project_id
	gar_project_id = var.management_project_id
	gar_region = var.regions[0]
	regions = [
		for index, value in data.google_compute_zones.available : {
			name = var.regions[index]
			zones = value.names
		}
	]
	allowed_networks = var.allowed_networks
}

module "keycloak_service" {
	/* Management doesn't get a cluster */
	count = (var.name == "management") ? 0 : 1
	source = "./modules/service"
	project_id = module.project.project_id
	name = "keycloak"
	host_name = "keycloak.roamtech.whitemire-technologies.com"
	dns_managed_zone_project_id = var.management_project_id
	dns_managed_zone_name = "root"
}

