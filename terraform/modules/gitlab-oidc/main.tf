resource "google_iam_workload_identity_pool" "default" {
  project                   = var.project_id
  workload_identity_pool_id = "gitlab-oidc"
}

resource "google_iam_workload_identity_pool_provider" "default" {
	for_each = var.issuers
  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.default.workload_identity_pool_id
  workload_identity_pool_provider_id = "gitlab-jwt-${each.key}"
  attribute_condition                = "attribute.namespace_path.startsWith(\"${var.gitlab_namespace_path}/\") || attribute.namespace_path == \"${var.gitlab_namespace_path}\""

  # See GitLab OIDC Custom Claims documentation for further details of assertions
  # https://docs.gitlab.com/ee/integration/google_cloud_iam.html#oidc-custom-claims
  attribute_mapping = {
    "google.subject"           = "assertion.project_id + \"::\" + assertion.ref", # Required and changed from gitlab.sub to avoid crossing the 127 bytes limit
    "attribute.project_path"   = "assertion.project_path",
    "attribute.project_id"     = "assertion.project_id",
    "attribute.namespace_id"   = "assertion.namespace_id",
    "attribute.namespace_path" = "assertion.namespace_path",
    "attribute.user_email"     = "assertion.user_email",
    "attribute.ref"            = "assertion.ref",
    "attribute.aud"            = "assertion.aud"
    "attribute.ref_type"       = "assertion.ref_type",
    "attribute.sub"            = "assertion.sub",
    "attribute.ci_config_sha"  = "assertion.ci_config_sha",
    "attribute.sha"            = "assertion.sha"
    "attribute.ref_protected"  = "assertion.ref_protected ? \"true\" : \"false\""
  }
  oidc {
    issuer_uri        = each.value
    allowed_audiences = []
  }
}

/* Service Account & IAM Permissions */
resource "google_service_account" "default" {
	project = var.project_id
	account_id = "gitlab-ci"
	display_name = "GitLab CI"
}

resource "google_project_iam_member" "viewer" {
  project = var.project_id
  role    = "roles/viewer"
  member  = google_service_account.default.member
}

resource "google_project_iam_member" "storage_admin" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = google_service_account.default.member
}

resource "google_project_iam_member" "admin" {
  project = var.project_id
  role    = "roles/admin"
  member  = google_service_account.default.member
}

resource "google_service_account_iam_member" "default" {
  service_account_id = google_service_account.default.id
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.default.name}/attribute.namespace_path/${var.gitlab_namespace_path}"
}

