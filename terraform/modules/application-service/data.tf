data "google_secret_manager_secret_version" "all" {
	for_each = google_secret_manager_secret.default
	project = var.project_id
	secret = each.value.secret_id
	fetch_secret_data = false
}

