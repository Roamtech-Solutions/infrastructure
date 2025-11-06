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
			project_id = var.project_id
      image         = "${var.gar}/${var.name}"
      host          = var.host
      service_group = var.service_group
			tag_short = substr(var.tag, 0, 7)
			security_policy = (lookup(local.values, "public", false)) ? "${var.service_group}-public" : var.service_group
    }),
  ]
	timeout = "600"
	atomic = true
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

/* Buckets */
resource "google_storage_bucket" "default" {
	for_each = toset(lookup(local.values, "gcs_buckets", []))
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

resource "google_storage_bucket_iam_member" "default" {
  for_each = google_storage_bucket.default
 	bucket = each.value.name
  role = "roles/storage.admin"
  member   = google_service_account.default.member
}

resource "google_storage_bucket_iam_member" "developers" {
  for_each = merge([
		for member in var.developers : {
			for k, v in google_storage_bucket.default : "${k}-${member}" => {
				name = v.name, member = member
			}
		}
	]...)
 	bucket = each.value.name
  role = "roles/storage.admin"
  member   = each.value.member
}

