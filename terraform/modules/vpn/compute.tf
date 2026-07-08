module "umig" {
  source             = "terraform-google-modules/vm/google//modules/umig"
  version            = "15.2.1"
  project_id         = var.project_id
  region             = var.region
  hostname           = "${var.region}-vpn"
  instance_template  = google_compute_instance_template.default.self_link
  subnetwork         = module.network.subnets_self_links[0]
  subnetwork_project = var.project_id
  named_ports = [
    {
      name = "http"
      port = 80
    }
  ]
  access_config = [[{ nat_ip = google_compute_address.vpn.address, network_tier = "PREMIUM" }]]
}

resource "google_compute_instance_template" "default" {
  project        = var.project_id
  name           = "vpn"
  machine_type   = "n1-standard-1"
  tags           = ["vpn", "allow-ssh-iap", "allow-health-check", "allow-lb-service"]
  can_ip_forward = true
  network_interface {
    network            = module.network.network_name
    subnetwork         = module.network.subnets_self_links[0]
    subnetwork_project = var.project_id
    access_config {
      nat_ip = google_compute_address.vpn.address
    }
  }
  disk {
    source_image = "debian-cloud/debian-12"
    auto_delete  = true
    boot         = true
    disk_size_gb = 40
  }
  scheduling {
    preemptible       = false
    automatic_restart = true
  }
  metadata = {
    startup-script-url = "${google_storage_bucket.assets.url}/vpn-startup.sh"
  }
  service_account {
    email  = google_service_account.default.email
    scopes = ["cloud-platform"]
  }
}
