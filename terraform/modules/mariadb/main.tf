/* === User Passwords === */
resource "random_password" "users" {
  for_each = toset(var.users)
  length   = 16
  special  = false
}

/* === Google Secret Manager Secrets and Versions === */
resource "google_secret_manager_secret" "users" {
  for_each  = random_password.users
  project   = var.project_id
  secret_id = "${var.name}-mariadb-${each.key}"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "users" {
  for_each = google_secret_manager_secret.users
  secret   = each.value.id
  secret_data = jsonencode({
		host = google_compute_instance.mariadb.network_interface[0].network_ip
    port = 3306
    user = each.key
    pass = random_password.users[each.key].result
  })
}

/* === MariaDB User Setup GSM Secrets and Versions === */
/* TODO: User creation script */
resource "google_secret_manager_secret" "user_install" {
  project   = var.project_id
  secret_id = "${var.name}-mariadb-user-install"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "user_install" {
  secret   = google_secret_manager_secret.user_install.id
  secret_data = templatefile(
    "${path.module}/resources/user-create.sql.tpl",
    {
      users = [for user in var.users : {
        name     = user
        password = random_password.users[user].result
      }]
    }
  )
}

/* --- Service Account --- */
resource "google_service_account" "mariadb" {
  account_id   = "${var.name}-mariadb"
  display_name = "${var.name}-mariadb"
  project      = var.project_id
}

/* TODO: Short hash of user creation script */
/* TODO: K8s job to run which connects to mariadb and runs the user creation script */

/* === Compute Instance === */
resource "google_compute_instance" "mariadb" {
  name         = "${var.name}-mariadb"
  project      = var.project_id
  zone         = data.google_compute_zones.available.names[0]
  machine_type = "e2-medium"

  tags = ["iap-ssh"]

  boot_disk {
    initialize_params {
      image = "projects/debian-cloud/global/images/family/debian-12"
      size  = 30
      type  = "pd-balanced"
    }
  }

  network_interface {
    network            = var.network_name
    subnetwork         = "${var.region}-${var.name}"
    subnetwork_project = var.project_id
    access_config {
      /* Ephemeral public IP, needed for setup */
    }
  }

  service_account {
    email  = google_service_account.mariadb.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  metadata_startup_script = file("${path.module}/resources/setup.sh")
}

