data "terraform_remote_state" "core" {
  backend = "gcs"
  config = {
    bucket = "${var.project_id}-tfstate"
    prefix = "management/core"
  }
}

data "google_client_config" "default" {}

data "google_container_cluster" "gh_actions" {
  project  = var.project_id
  name     = data.terraform_remote_state.core.outputs.gh_actions_cluster.name
  location = data.terraform_remote_state.core.outputs.gh_actions_cluster.region
}

