/* Ingress */
resource "google_compute_global_address" "default" {
  project = var.project_id
  name    = var.name
}

resource "google_dns_record_set" "default" {
  project      = var.dns_managed_zone_project_id
  name         = "${var.host}."
 	managed_zone = var.dns_managed_zone_name
  type         = "A"
  ttl          = "300"
  rrdatas      = [google_compute_global_address.default.address]
}

/* Admin password */
resource "random_password" "admin" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "google_secret_manager_secret" "admin" {
  project   = var.project_id
  secret_id = "keycloak-admin-password"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "admin" {
  secret      = google_secret_manager_secret.admin.id
  secret_data = random_password.admin.result
}

/* Helm */
resource "helm_release" "keycloak" {
  name       = "keycloak"
  chart      = "${path.module}/../../../helm/charts/keycloak"
	namespace = "keycloak"
	values = [yamlencode({
		host = var.host
	})]

	create_namespace = true
	# 15 Minute timeout, can take longer on intial cluster setup.
	timeout = 900
}

