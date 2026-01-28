/* === User Passwords === */
resource "random_password" "default" {
  for_each = toset(local.users)
  length   = 16
  special  = false
}

/* === Google Secret Manager Secrets and Versions === */
resource "google_secret_manager_secret" "default" {
  for_each  = random_password.default
  project   = var.project_id
  secret_id = "${var.name}-mariadb-${each.key}"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "default" {
  for_each = google_secret_manager_secret.default
  secret   = each.value.id
  secret_data = jsonencode({
    host = module.cloudsql.private_ip_address
    port = 3306
    user = each.key
    pass = random_password.default[each.key].result
  })
}

/* === MariaDB User Setup GSM Secrets and Versions === */
/* TODO: User creation script */
resource "google_secret_manager_secret" "default" {
  for_each  = random_password.default
  project   = var.project_id
  secret_id = "${var.name}-mariadb-user-install"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "default" {
  for_each = google_secret_manager_secret.default
  secret   = each.value.id
  secret_data = templatefile(
		"${path.module}/resources/user-create.sql.tpl",
		{
			users = [ for local.users 
		}
	)
}
/* TODO: Short hash of user creation script */
/* TODO: K8s job to run which connects to mariadb and runs the user creation script */

