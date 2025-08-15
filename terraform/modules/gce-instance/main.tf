resource "google_service_account" "default" {
  project      = var.project_id
  account_id   = var.name
  display_name = "${var.name} service account"
}

resource "google_compute_instance" "default" {
  name         = var.name
  project      = var.project_id
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = var.boot_disk_image
      size  = var.boot_disk_size
      type  = var.boot_disk_type
    }
  }

  network_interface {
    network            = var.network
    subnetwork         = var.subnetwork
    subnetwork_project = var.project_id
    # No access_config block to disable public IP
  }

  tags = distinct(concat(var.tags, [var.name]))

  metadata = var.metadata

  service_account {
    email  = google_service_account.default.email
    scopes = ["cloud-platform"]
  }
  metadata_startup_script = var.startup_script
}

resource "google_compute_firewall" "allow_ssh_iap" {
  name    = "${google_compute_instance.default.name}-allow-ssh-iap"
  project = var.project_id
  network = var.network

  direction = "INGRESS"
  priority  = 1000

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"] # IAP TCP forwarding IP range

  target_tags = distinct(concat(var.tags, [var.name]))
  description = "Allow SSH from IAP to ${google_compute_instance.default.name}"
}
