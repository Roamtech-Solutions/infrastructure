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
}

