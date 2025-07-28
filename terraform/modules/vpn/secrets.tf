resource "random_password" "mongo_key" {
  length  = 64
  special = false
}

resource "random_password" "mongo" {
  for_each = toset(["mongo-admin-user-password", "mongo-vpn-user-password"])
  length   = 24
  special  = false
}

resource "google_secret_manager_secret" "default" {
  for_each  = local.secrets
  project   = var.project_id
  secret_id = "vpn-${each.key}"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "default" {
  for_each    = google_secret_manager_secret.default
  secret      = each.value.id
  secret_data = local.secrets[each.key]
}

