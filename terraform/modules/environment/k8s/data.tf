data "terraform_remote_state" "core" {
  backend  = "gcs"
  config = {
    bucket = "${var.management_project_id}-tfstate"
		prefix = "${var.name}/core"
  }
}

data "terraform_remote_state" "infra" {
  backend  = "gcs"
  config = {
    bucket = "${var.management_project_id}-tfstate"
		prefix = "${var.name}/infra"
  }
}

data "terraform_remote_state" "management" {
  backend  = "gcs"
  config = {
    bucket = "${var.management_project_id}-tfstate"
		prefix = "management"
  }
}

data "google_client_config" "default" {}

data "google_container_cluster" "default" {
	project = local.project_id
  name     = data.terraform_remote_state.infra.outputs.gke_cluster.name
  location     = data.terraform_remote_state.infra.outputs.gke_cluster.region
}

