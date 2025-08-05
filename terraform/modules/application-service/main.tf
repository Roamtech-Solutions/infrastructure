resource "helm_release" "application_service" {
  name             = var.name
  chart            = "${path.module}/../../../helm/charts/application-service"
  namespace        = var.service_group
  create_namespace = true
  values = [
    yamlencode({
      image        = "${var.gar}/${var.name}:${var.tag}"
      host         = (var.ingress != null) ? var.ingress.host : ""
      serviceGroup = var.service_group
    }),
    var.values,
  ]
}

/* Ingress */
resource "google_compute_global_address" "default" {
  for_each = local.ingress
  project  = var.project_id
  name     = "${var.service_group}-${var.name}"
}

resource "google_dns_record_set" "default" {
  for_each     = local.ingress
  project      = each.value.dns_managed_zone.project_id
  name         = "${each.value.host}."
  managed_zone = each.value.dns_managed_zone.name
  type         = "A"
  ttl          = "300"
  rrdatas      = [google_compute_global_address.default.0.address]
}

/* === Secrets === */
resource "google_secret_manager_secret" "default" {
	for_each = toset(local.secrets)
	project = var.project_id
	secret_id = "${var.service_group}-${lower(replace(each.key, "_", "-"))}"
  replication {
    auto {}
  }
}

