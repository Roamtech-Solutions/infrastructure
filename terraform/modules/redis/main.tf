# === User Credentials === #
resource "random_password" "users" {
  for_each = toset(var.users)
  length   = 64
  special  = false
}

resource "google_secret_manager_secret" "users" {
	for_each = toset(var.users)
  project   = var.project_id
  secret_id = "${var.prefix}-${each.key}"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "users" {
	for_each = google_secret_manager_secret.users
	secret = each.value.id
  secret_data = jsonencode({
		user = each.key
		pass = random_password.users[each.key].result
		host = "redis"
		port = var.port
	})
}

# === Redis Configuration === #
resource "google_secret_manager_secret" "default" {
  project   = var.project_id
  secret_id = "redis-config"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "default" {
  secret = google_secret_manager_secret.default.id
  secret_data = jsonencode({
    conf = templatefile(
      "${path.module}/template/redis.conf",
      {
        port           = var.port
        config_file    = var.config_file
        users          = local.users
        enable_cluster = var.enable_cluster
      }
    ),
    users = local.users
  })
}

# === Helm Deployment === #
resource "helm_release" "redis" {
  name  = "redis"
  chart = "${path.module}/../../../helm/charts/redis"
}

