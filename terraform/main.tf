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

module "gke" {
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

module "keycloak" {
	source = "./modules/keycloak"
	project_id = module.project.project_id
	name = "keycloak"
	host_name = "keycloak.roamtech.whitemire-technologies.com"
	dns_managed_zone_project_id = var.management_project_id
	dns_managed_zone_name = "root"
	depends_on = [module.gke]
}

