resource "google_service_account" "default" {
  project    = var.project_id
  account_id = "${var.service_group}-${var.name}"
}

# Enable service account to be used in a Kubernetes Pod as a workload identity
resource "google_service_account_iam_member" "default" {
  service_account_id = google_service_account.default.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${var.service_group}/${var.name}]"
}

resource "helm_release" "application_service" {
  name             = var.name
  chart            = "${path.module}/../../../helm/charts/application-service"
  namespace        = var.service_group
  create_namespace = true
  values = [
    var.values,
    yamlencode({
      project_id      = var.project_id
      image           = "${var.gar}/${var.name}"
      host            = var.host
      service_group   = var.service_group
      tag_short       = (length(var.tag) <= 16) ? var.tag : substr(var.tag, 0, 7)
      security_policy = local.security_policy
    }),
  ]
  timeout         = "600"
  atomic          = true
  cleanup_on_fail = true
}

/* === Secrets === */
resource "google_secret_manager_secret" "default" {
  for_each  = toset(local.secrets)
  project   = var.project_id
  secret_id = "${var.service_group}-${var.name}-${lower(replace(each.key, "_", "-"))}"
  replication {
    auto {}
  }
}

/* Generated Wordpress Secrets */
resource "random_password" "wordpress" {
  for_each         = toset(local.wordpress_addtional_secrets)
  length           = 64
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "google_secret_manager_secret_version" "wordpress" {
  for_each    = toset(local.wordpress_addtional_secrets)
  secret      = google_secret_manager_secret.default[each.key].id
  secret_data = random_password.wordpress[each.key].result
  depends_on  = [google_secret_manager_secret.default]
}

/* Buckets */
resource "google_storage_bucket" "default" {
  for_each                    = toset(lookup(local.values, "gcs_buckets", []))
  project                     = var.project_id
  name                        = "${var.environment}-${var.service_group}-${var.name}-${each.key}"
  force_destroy               = true
  location                    = var.region
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true
  versioning {
    enabled = true
  }
}

resource "google_storage_bucket" "public" {
  for_each                    = toset(lookup(local.values, "gcs_buckets_public", []))
  project                     = var.project_id
  name                        = "${var.environment}-${var.service_group}-public-${var.name}-${each.key}"
  force_destroy               = true
  location                    = var.region
  uniform_bucket_level_access = true
  versioning {
    enabled = true
  }
}

# resource "google_storage_bucket_iam_member" "member" {
#   for_each = google_storage_bucket.public
#   bucket   = each.value.name
#   role     = "roles/storage.objectViewer"
#   member   = "allUsers"
# }
resource "google_storage_bucket_iam_member" "member" {
  for_each = toset(lookup(local.values, "gcs_buckets_public", []))
  bucket   = google_storage_bucket.public[each.key].name
  role     = "roles/storage.objectViewer"
  member   = "allUsers"
}

resource "google_storage_bucket_iam_member" "default" {
  for_each = local.all_buckets
  bucket   = each.value.name
  role     = "roles/storage.admin"
  member   = google_service_account.default.member
}

resource "google_storage_bucket_iam_member" "developers" {
  for_each = merge([
    for member in var.developers : {
      for k, v in local.all_buckets : "${k}-${member}" => {
        name = v.name, member = member
      }
    }
  ]...)
  bucket = each.value.name
  role   = "roles/storage.admin"
  member = each.value.member
}

