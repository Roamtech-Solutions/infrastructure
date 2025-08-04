resource "random_password" "default" {
  for_each = toset(var.users)
  length   = 64
  special  = false
}

# Redis configuration
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

resource "helm_release" "redis" {
  name  = "redis"
  chart = "${path.module}/../../../helm/charts/redis"

  create_namespace = true
  # 15 Minute timeout, can take longer on intial cluster setup.
  timeout = 900
}

