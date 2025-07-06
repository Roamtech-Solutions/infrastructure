data "google_client_config" "default" {}

data "google_container_cluster" "default" {
	project = module.project.project_id
  name     = module.gke.name
  location = var.region
}

