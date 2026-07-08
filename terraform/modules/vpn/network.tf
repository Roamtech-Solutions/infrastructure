module "network" {
  source       = "terraform-google-modules/network/google"
  version      = "18.1.0"
  project_id   = var.project_id
  network_name = "vpn"
  subnets = [
    {
      subnet_name           = "default"
      subnet_ip             = "10.10.0.0/20"
      subnet_region         = var.region
      subnet_private_access = true
      subnet_flow_logs      = true
    }
  ]
  shared_vpc_host = false
}

resource "google_dns_record_set" "vpn" {
  project      = var.project_id
  name         = "${var.host}."
  managed_zone = var.dns_managed_zone.name
  type         = "A"
  ttl          = 60
  rrdatas      = [module.lb.external_ip]
}

resource "google_compute_address" "vpn" {
  project = var.project_id
  name    = "vpn"
  region  = var.region
  lifecycle {
    prevent_destroy = false
  }
}

module "lb" {
  source                          = "GoogleCloudPlatform/lb-http/google"
  version                         = "14.2.0"
  project                         = var.project_id
  name                            = "vpn-web-console"
  target_tags                     = ["allow-lb-service"]
  network                         = module.network.network_id
  firewall_networks               = [module.network.network_id]
  firewall_projects               = [var.project_id]
  ssl                             = true
  managed_ssl_certificate_domains = ["${var.host}."]
  https_redirect                  = true
  security_policy                 = google_compute_security_policy.default.self_link
  backends = {
    vpn = {
      project    = var.project_id
      protocol   = "HTTP"
      port       = 80
      port_name  = "http"
      enable_cdn = false
      health_check = {
        check_interval_sec  = 1
        healthy_threshold   = 4
        timeout_sec         = 1
        unhealthy_threshold = 5
        port                = 80
        request_path        = "/check"
        host                = nonsensitive(module.umig.instances_details[0].network_interface.0.network_ip)
        logging             = true
      }
      groups = [{ group = module.umig.self_links[0] }]
      iap_config = {
        enable = false
      }
      log_config = {
        enable = false
      }
    }
  }
}

resource "google_compute_firewall" "allow_iap" {
  project = var.project_id
  name    = "vpn-allow-ssh-iap"
  network = module.network.network_id
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["allow-ssh-iap"]
}

resource "google_compute_firewall" "vpn" {
  project = var.project_id
  name    = "vpn"
  network = module.network.network_id
  allow {
    protocol = "udp"
    ports    = ["14145"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["vpn"]
}

