module "project" {
  source            = "terraform-google-modules/project-factory/google"
  version           = "18.3.0"
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
  source     = "../../vpn"
  project_id = module.project.project_id
  region     = var.region
  host       = "vpn.roamtech.whitemire-technologies.com"
  dns_managed_zone = {
    project_id = module.project.project_id
    name       = "roamtech-whitemire-technologies-com"
  }
  allowed_networks = var.allowed_networks
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
  source              = "../../github-oidc"
  project_id          = module.project.project_id
  github_organisation = var.github_organisation
}

/* Allow uploads to the Docker registry */
resource "google_artifact_registry_repository_iam_member" "github_oidc_docker" {
  for_each   = google_artifact_registry_repository.service_groups
  project    = module.project.project_id
  location   = each.value.location
  repository = each.value.name
  role       = "roles/artifactregistry.writer"
  member     = module.github_oidc.principal_set
}

/* TODO: Restrict admin access for CI account */
resource "google_project_iam_member" "ci_admin" {
  project = module.project.project_id
  role    = "roles/admin"
  member  = module.github_oidc.principal_set
}

/* Allow management of the state bucket */
resource "google_storage_bucket_iam_member" "github-tfstate-admin" {
  bucket = google_storage_bucket.tfstate.name
  role   = "roles/storage.admin"
  member = module.github_oidc.principal_set
}

/* Allow management of the values bucket */
resource "google_storage_bucket_iam_member" "github-values-admin" {
  bucket = google_storage_bucket.values.name
  role   = "roles/storage.admin"
  member = module.github_oidc.principal_set
}

/* DNS */
resource "google_dns_managed_zone" "default" {
  for_each = toset(var.hosts)
  project  = module.project.project_id
  name     = replace(each.key, ".", "-")
  dns_name = "${each.key}."
}

/* Docker GARs */
resource "google_artifact_registry_repository" "service_groups" {
  for_each               = toset(var.service_groups)
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
    enablement_config = "DISABLED"
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

/* GitHub Actions Set up */
# module "github_actions" {
#   source              = "../../github-actions"
#   project_id          = module.project.project_id
#   github_organisation = var.github_organisation
#   prefixes            = var.service_groups
# }

/* === GitHub Actions === */
resource "google_secret_manager_secret" "gh_app" {
  for_each  = toset(["id", "installation_id", "private_key"])
  project   = module.project.project_id
  secret_id = "gh-app-${replace(each.key, "_", "-")}"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "gh_app" {
  for_each = {
    for k, v in google_secret_manager_secret.gh_app : k => v
    if k != "private_key"
  }
  secret      = each.value.id
  secret_data = var.github_app[each.key]
}

module "gke_gh_actions" {
  source               = "../../gke"
  name                 = "gh-actions"
  project_id           = module.project.project_id
  registry_project_ids = [module.project.project_id]
  region               = var.region
  allowed_networks = merge(
    var.allowed_networks,
    {
      "vpn" = "${module.vpn.address}/32"
    }
  )
  jump_box_enabled = false
}


/* Shopify Email Verification & DMARC Records for adenzo.co.ke */
locals {
  shopify_cnames = {
    "dch._domainkey"           = "dkim1.d0d1e838e436.p721.email.myshopify.com."
    "dch2._domainkey"          = "dkim2.d0d1e838e436.p721.email.myshopify.com."
    "pdk1._domainkey.mailerf4q" = "dkim3.b5c40c9207d.p719.email.myshopify.com."
    "pdk2._domainkey.mailerf4q" = "dkim4.b5c40c9207d.p719.email.myshopify.com."
    "mailerdch"                = "d0d1e838e436.p721.email.myshopify.com."
    "mailerf4q"                = "b5c40c9207d.p719.email.myshopify.com."
  }

  shopify_txts = {
    "_dmarc" = "\"v=DMARC1; p=none;\""
  }
}

resource "google_dns_record_set" "shopify_cnames" {
  for_each     = local.shopify_cnames
  project      = module.project.project_id
  managed_zone = google_dns_managed_zone.default["adenzo.co.ke"].name
  name         = "${each.key}.adenzo.co.ke."
  type         = "CNAME"
  ttl          = 300
  rrdatas      = [each.value]
}

resource "google_dns_record_set" "shopify_txts" {
  for_each     = local.shopify_txts
  project      = module.project.project_id
  managed_zone = google_dns_managed_zone.default["adenzo.co.ke"].name
  name         = "${each.key}.adenzo.co.ke."
  type         = "TXT"
  ttl          = 300
  rrdatas      = [each.value]
}