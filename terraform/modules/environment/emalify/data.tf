/* === Available Zones in the Region === */
data "google_compute_zones" "available" {
  project = local.project_id
  region  = var.region
}

/* === Remote States === */
data "terraform_remote_state" "core" {
  backend = "gcs"
  config = {
    bucket = "${var.management_project_id}-tfstate"
    prefix = "${var.name}/core"
  }
}

data "terraform_remote_state" "infra" {
  backend = "gcs"
  config = {
    bucket = "${var.management_project_id}-tfstate"
    prefix = "${var.name}/infra"
  }
}

data "terraform_remote_state" "management" {
  backend = "gcs"
  config = {
    bucket = "${var.management_project_id}-tfstate"
    prefix = "management"
  }
}

/* === GKE Cluster Information === */
data "google_client_config" "default" {}

data "google_container_cluster" "default" {
  project  = local.project_id
  name     = data.terraform_remote_state.infra.outputs.gke_cluster.name
  location = data.terraform_remote_state.infra.outputs.gke_cluster.region
}

/* === Services === */
data "google_storage_bucket_object_content" "application_service_values" {
  for_each = toset(local.application_services)
  name     = "${var.name}/${var.service_group}/${each.key}.yaml"
  bucket   = "${var.management_project_id}-values"
}

data "google_storage_bucket_objects" "application_services" {
  bucket     = "${var.management_project_id}-values"
  match_glob = "${var.name}/${var.service_group}/*.yaml"
}

