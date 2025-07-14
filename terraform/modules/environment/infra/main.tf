module "network_security" {
	source = "../../network-security"
	project_id = local.project_id
	allowed_networks = var.allowed_networks
}

module "gke" {
	source = "../../gke"
	name = var.name
	project_id = local.project_id
	docker_gar = data.terraform_remote_state.management.outputs.docker_gar
	region = var.region
	allowed_networks = var.allowed_networks
}

/* Allow the GitLab CI service account to manage the project */
resource "google_project_iam_member" "gitlab_admin" {
  project = local.project_id
  role    = "roles/admin"
  member  = data.terraform_remote_state.management.outputs.gitlab_ci_sa_member
}

