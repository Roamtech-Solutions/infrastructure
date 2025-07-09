data "google_client_config" "default" {}

data "google_container_cluster" "default" {
	project = module.project.project_id
  name     = module.gke.name
  location = var.region
}

data "terraform_remote_state" "management" {
  backend  = "gcs"
  config = {
    bucket = "${var.management_project_id}-tfstate"
		prefix = "management"
  }
}

