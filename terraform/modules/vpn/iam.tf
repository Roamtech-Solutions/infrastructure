resource "google_service_account" "default" {
  project      = var.project_id
  account_id   = "vpn-sa"
  display_name = "VPN Service Account"
}

resource "google_project_iam_binding" "sa_logging" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  members = [
    google_service_account.default.member
  ]
}

resource "google_storage_bucket_iam_member" "assets" {
  bucket = google_storage_bucket.assets.name
  role   = "roles/storage.objectViewer"
  member = google_service_account.default.member
}

resource "google_secret_manager_secret_iam_member" "accessor_all" {
  for_each = {
    for k, v in google_secret_manager_secret.default : k => v
    if k != "web-console-credentials"
  }
  project   = var.project_id
  secret_id = google_secret_manager_secret.default[each.key].id
  role      = "roles/secretmanager.secretAccessor"
  member    = google_service_account.default.member
}

resource "google_secret_manager_secret_iam_member" "admin" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.default["web-console-credentials"].id
  role      = "roles/secretmanager.secretVersionAdder"
  member    = google_service_account.default.member
}

