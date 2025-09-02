/* Admin password */
resource "random_password" "admin" {
  length           = 16
  special          = false
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "google_secret_manager_secret" "admin" {
  project   = var.project_id
  secret_id = "${var.service_group}-keycloak-admin"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "admin" {
  secret      = google_secret_manager_secret.admin.id
  secret_data = random_password.admin.result
}

/* Admin CLI */
# resource "google_secret_manager_secret" "admin-cli" {
#   for_each  = toset(["guid", "secret"])
#   project   = var.project_id
#   secret_id = "keycloak-admin-cli-${each.key}"
#   replication {
#     auto {}
#   }
# }

/* Helm */
resource "helm_release" "keycloak" {
  name      = "keycloak"
  chart     = "${path.module}/../../../helm/charts/keycloak"
  namespace = var.service_group
  values = [yamlencode({
    host = var.host
		port = 9000
		service_group = var.service_group
  })]

  create_namespace = true

	timeout = 900
}

