resource "google_storage_bucket" "tfstate" {
  project                     = var.project_id
  name                        = "${var.project_id}-tfstate"
  force_destroy               = false
  location                    = var.region
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true
  versioning {
    enabled = true
  }
}

resource "google_service_account" "gitlab_ci" {
	project = var.project_id
	account_id = "gitlab-ci"
	display_name = "GitLab CI"
}

module "gitlab_oidc" {
  source = "gitlab.com/gitlab-com/gcp-oidc/google"
  version = "3.3.0"
  google_project_id = var.project_id
  gitlab_project_id = var.gitlab_project_id
  oidc_service_account = {
    "sa" = {
      sa_email  = google_service_account.gitlab_ci.email
      attribute = "attribute.project_id/${var.gitlab_project_id}"
    }
  }
}

