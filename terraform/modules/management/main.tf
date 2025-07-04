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
  project                     = module.project.project_id
  name                        = "${module.project.project_id}-tfstate"
  force_destroy               = false
  location                    = var.region
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true
  versioning {
    enabled = true
  }
}

/* GitLab CI */
resource "google_service_account" "gitlab_ci" {
	project = module.project.project_id
	account_id = "gitlab-ci"
	display_name = "GitLab CI"
}

resource "google_project_iam_member" "gitlab_ci" {
  project = module.project.project_id
  role    = "roles/storage.admin"
  member  = google_service_account.gitlab_ci.member
}

module "gitlab_oidc" {
  source = "gitlab.com/gitlab-com/gcp-oidc/google"
  version = "3.3.0"
  google_project_id = module.project.project_id
  gitlab_project_id = var.gitlab_project_id
  oidc_service_account = {
    "sa" = {
      sa_email  = google_service_account.gitlab_ci.email
      attribute = "attribute.project_id/${var.gitlab_project_id}"
    }
  }
}

/* DNS */
resource "google_dns_managed_zone" "root" {
  project     = module.project.project_id
  name        = "root"
  dns_name    = "roamtech.whitemire-technologies.com."
  description = "Root zone"
}

