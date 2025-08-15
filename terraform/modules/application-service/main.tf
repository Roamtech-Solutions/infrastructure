resource "helm_release" "application_service" {
  name             = var.name
  chart            = "${path.module}/../../../helm/charts/application-service"
  namespace        = var.service_group
  create_namespace = true
  values = [
    yamlencode({
      image         = "${var.gar}/${var.name}"
      host          = var.host
      service_group = var.service_group
    }),
    var.values,
  ]
}

/* === Secrets === */
resource "google_secret_manager_secret" "default" {
  for_each  = toset(local.secrets)
  project   = var.project_id
  secret_id = "${var.service_group}-${lower(replace(each.key, "_", "-"))}"
  replication {
    auto {}
  }
}

