/* === CloudSQL Instance === */
module "cloudsql" {
  source               = "GoogleCloudPlatform/sql-db/google//modules/mysql"
  version              = "26.1.1"
  name                 = var.name
  random_instance_name = true
  project_id           = var.project_id
  database_version     = var.database_version
  region               = var.region
  deletion_protection  = var.deletion_protection
  disk_size            = var.disk_size

  database_flags = [
    { name = "audit_log", value = "ON" }
  ]

  tier                            = var.tier_primary
  zone                            = var.zone
  availability_type               = "REGIONAL"
  maintenance_window_day          = 7
  maintenance_window_hour         = 0
  maintenance_window_update_track = "stable"

  user_labels = {}

  insights_config = {
    query_plans_per_minute  = 5
    query_string_length     = 1024
    record_application_tags = true
    record_client_address   = true
  }

  ip_configuration = {
    ipv4_enabled       = false
    ssl_mode           = "ENCRYPTED_ONLY"
    private_network    = var.network.id
    allocated_ip_range = null
  }

  backup_configuration = {
    enabled                        = true
    binary_log_enabled             = true
    start_time                     = "00:00"
    location                       = "EU"
    transaction_log_retention_days = null
    retained_backups               = 7
    retention_unit                 = "COUNT"
  }

  db_charset   = "utf8mb4"
  db_collation = "utf8mb4_general_ci"

	user_name = "root"
	user_password = random_password.default["root"].result

  additional_users = [
    for k, v in random_password.default : {
      name            = k
      password        = v.result
      random_password = false
			# TODO: Try restricting SQL user access to pod network
      host            = "%"
      type            = "BUILT_IN"
    } if k != "root"
  ]
}

/* === Generated root user password secret manager === */
resource "random_password" "default" {
	for_each = toset(local.users)
  length           = 16
  special          = false
}

resource "google_secret_manager_secret" "default" {
	for_each = random_password.default
  project   = var.project_id
  secret_id = "${var.name}-cloudsql-${each.key}"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "default" {
	for_each = google_secret_manager_secret.default
  secret = each.value.id
  secret_data = jsonencode({
    host = module.cloudsql.private_ip_address
    port = 3306
    user = each.key
    pass = random_password.default[each.key].result
  })
}

resource "google_secret_manager_secret" "cert" {
  project   = var.project_id
  secret_id = "${var.name}-cloudsql-cert"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "cert" {
  secret = google_secret_manager_secret.cert.id
  secret_data = jsonencode({
		data = module.cloudsql.instance_server_ca_cert.0.cert
		})
}

