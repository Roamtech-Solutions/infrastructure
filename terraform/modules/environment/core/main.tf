module "project" {
  source            = "terraform-google-modules/project-factory/google"
  version           = "18.0.0"
  name              = var.name
  random_project_id = true
  org_id            = var.organisation
  billing_account   = var.billing_account

	deletion_policy   = "DELETE"

  /* Services */
  activate_apis               = var.services
  disable_services_on_destroy = false
  disable_dependent_services  = false

  labels = {
    env = var.name
  }
}

/* Allow CI to manage the project */
resource "google_project_iam_member" "ci_admin" {
  project = module.project.project_id
  role    = "roles/admin"
  member  = data.terraform_remote_state.management.outputs.ci_iam_member
}

