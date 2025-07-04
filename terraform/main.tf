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

resource "google_storage_bucket" "tfstate" {
	/* TF state only stored in management */
	count = (var.name == "management") ? 1 : 0
  project                     = module.project.project_id
  name                        = "${module.project.project_id}-tfstate"
  force_destroy               = false
  location                    = var.regions[0]
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true
  versioning {
    enabled = true
  }
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

