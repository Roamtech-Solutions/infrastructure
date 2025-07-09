resource "helm_release" "application_service" {
	name = var.name
  chart      = "${path.module}/../../../helm/charts/application-service"
	values = [yamlencode({
		image =  "${var.gar}/${var.name}:${var.tag}"
		port = 80
		ingress = (var.ingress != null)
		host = var.ingress.host
	})]
	# 15 Minute timeout, can take longer on intial cluster setup.
	timeout = 900
}

/* Ingress */
resource "google_compute_global_address" "default" {
	for_each = (var.ingress != null) ? toset(["0"]) : toset([])
  project = var.project_id
  name    = var.name
}

resource "google_dns_record_set" "default" {
	for_each = (var.ingress != null) ? toset(["0"]) : toset([])
  project      = var.ingress.dns_managed_zone.project_id
	/* TODO: Get domain name from a variable */
  name         = "${var.ingress.host}."
 	managed_zone = var.ingress.dns_managed_zone.name
  type         = "A"
  ttl          = "300"
  rrdatas      = [google_compute_global_address.default.0.address]
}

