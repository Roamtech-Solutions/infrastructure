resource "google_compute_global_address" "default" {
  project = var.project_id
  name    = var.name
}

resource "google_dns_record_set" "default" {
  project      = var.dns_managed_zone_project_id
  name         = "${var.host_name}."
 	managed_zone = var.dns_managed_zone_name
  type         = "A"
  ttl          = "300"
  rrdatas      = [google_compute_global_address.default.address]
}

