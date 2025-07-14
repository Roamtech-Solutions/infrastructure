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

/* === GitLab CI === */
module "gitlab_oidc" {
	source = "../gitlab-oidc"
	project_id = module.project.project_id
	issuers = {
		default = "https://gitlab.com"
		gcp-gitlab = "https://auth.gcp.gitlab.com/oidc/roamtech1"
	}
	/* TODO: Don't hardcode GitLab namespace path */
	gitlab_namespace_path = "roamtech1"
}

/* Allow GitLab CI to update files in the values bucket */
resource "google_storage_bucket_iam_member" "member" {
  bucket = google_storage_bucket.values.name
  role = "roles/storage.admin"
	member = module.gitlab_oidc.principal_set
}

resource "google_artifact_registry_repository_iam_member" "gitlab_ci_docker" {
  project    = module.project.project_id
  location   = google_artifact_registry_repository.docker.location
  repository = google_artifact_registry_repository.docker.name
  role       = "roles/artifactregistry.writer"
	member = module.gitlab_oidc.principal_set
}

/* DNS */
resource "google_dns_managed_zone" "root" {
  project     = module.project.project_id
  name        = "root"
  dns_name    = "roamtech.whitemire-technologies.com."
  description = "Root zone"
}

/* Docker GAR */
resource "google_artifact_registry_repository" "docker" {
  project                = module.project.project_id
  location               = var.region
  repository_id          = "docker"
  description            = "Docker Repository"
  format                 = "DOCKER"
  cleanup_policy_dry_run = false
  docker_config {
    immutable_tags = true
  }
  vulnerability_scanning_config {
    enablement_config = "INHERITED"
  }
}

/* Helm values bucket */
resource "google_storage_bucket" "values" {
  project                     = module.project.project_id
  name                        = "${module.project.project_id}-values"
  force_destroy               = false
  location                    = var.region
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true
  versioning {
    enabled = true
  }
}

