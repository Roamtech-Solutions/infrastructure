module "project" {
  source            = "terraform-google-modules/project-factory/google"
  version           = "18.0.0"
	name              = var.name
  random_project_id = true
  org_id            = var.organisation
  billing_account   = var.billing_account

	deletion_policy = "DELETE"

  /* Services */
  activate_apis               = var.services
  disable_services_on_destroy = false
  disable_dependent_services  = false

  labels = {
    env = var.name
  }
}

module "vpn" {
	count = 0
	source = "../vpn"
	project_id = module.project.project_id
	region = var.region
	host = "vpn.roamtech.whitemire-technologies.com"
	dns_managed_zone = {
		project_id = module.project.project_id
		name = "root"
	}
	allowed_networks = {
		"bob" = "81.151.140.163/32"
	}
}

resource "google_storage_bucket" "tfstate" {
  project                     = module.project.project_id
  name                        = "${module.project.project_id}-tfstate"
  force_destroy               = true
  location                    = var.region
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true
  versioning {
    enabled = true
  }
}

/* === GitHub CI === */
module "github_oidc" {
	source = "../github-oidc"
	project_id = module.project.project_id
	/* TODO: Don't hardcode GitHub org */
	github_organisation = "Roamtech-Solutions"
}

/* Allow uploads to the Docker registry */
resource "google_artifact_registry_repository_iam_member" "github_oidc_docker" {
  for_each   = google_artifact_registry_repository.service_groups
  project    = module.project.project_id
  location   = each.value.location
  repository = each.value.name
  role       = "roles/artifactregistry.writer"
	member = module.github_oidc.principal_set
}

/* Allow management of the state bucket */
resource "google_storage_bucket_iam_member" "github-tfstate-admin" {
  bucket = google_storage_bucket.tfstate.name
  role = "roles/storage.admin"
	member = module.github_oidc.principal_set
}

/* Allow management of the values bucket */
resource "google_storage_bucket_iam_member" "github-values-admin" {
  bucket = google_storage_bucket.values.name
  role = "roles/storage.admin"
	member = module.github_oidc.principal_set
}

# /* === GitLab CI === */
# module "gitlab_oidc" {
# 	source = "../gitlab-oidc"
# 	project_id = module.project.project_id
# 	issuers = {
# 		default = "https://gitlab.com"
# 		gcp-gitlab = "https://auth.gcp.gitlab.com/oidc/roamtech1"
# 	}
# 	/* TODO: Don't hardcode GitLab namespace path */
# 	gitlab_namespace_path = "roamtech1"
# }
# 
# /* Allow GitLab CI to update files in the values bucket */
# resource "google_storage_bucket_iam_member" "member" {
#   bucket = google_storage_bucket.values.name
#   role = "roles/storage.admin"
# 	member = module.gitlab_oidc.principal_set
# }
# 
# /* TODO: Restrict token creation to the GitLab service account */
# resource "google_project_iam_member" "gitlab_ci_sa_user" {
#   project    = module.project.project_id
#   role    = "roles/iam.serviceAccountTokenCreator"
# 	member = module.gitlab_oidc.principal_set
# }
# 
# resource "google_artifact_registry_repository_iam_member" "gitlab_ci_docker" {
#   project    = module.project.project_id
#   location   = google_artifact_registry_repository.docker.location
#   repository = google_artifact_registry_repository.docker.name
#   role       = "roles/artifactregistry.writer"
# 	member = module.gitlab_oidc.principal_set
# }

/* DNS */
resource "google_dns_managed_zone" "default" {
	for_each = toset(var.hosts)
  project     = module.project.project_id
  name    = replace(each.key, ".", "-")
  dns_name    = "${each.key}."
}

/* Docker GARs */
resource "google_artifact_registry_repository" "service_groups" {
	for_each = toset(var.service_groups)
  project                = module.project.project_id
  location               = var.region
  repository_id          = each.key
  description            = "${title(each.key)} Docker Repository"
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

