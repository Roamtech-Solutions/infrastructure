/* --- MySQL Database --- */
module "cloudsql" {
  source           = "../cloudsql"
  project_id       = var.project_id
  name             = var.name
  database_version = "MYSQL_8_0"
  region           = var.region
  zone             = data.google_compute_zones.available.names[0]
  read_replica = null
  network             = var.network
  tier_primary        = "db-f1-micro"
  users               = []
  deletion_protection = true
  database_flags      = []
  developers          = var.developers
}

/* === Service Accounts & Related Permissions === */

/* --- SonarQube --- */
resource "google_service_account" "default" {
  account_id   = var.name
  project      = var.project_id
}

resource "google_project_iam_member" "default_roles" {
  for_each = toset(local.default_roles)
  project  = var.project_id
  role     = each.value
  member   = google_service_account.default.member
}

/* CloudSQL Instances Access */
# resource "google_project_iam_member" "default_cloudsql_client" {
#   for_each = local.database_connections
#   project  = var.project_id
#   role     = "roles/cloudsql.client"
#   member   = google_service_account.default.member
#   condition {
#     title = "OnlyThisInstance"
#     #description = "Allow connecting only a specific Cloud SQL instance"
#     expression = "resource.name == 'projects/${var.project_id}/instances/${each.key}'"
#   }
# }

/* Database User */
# resource "google_sql_user" "default_iam_user" {
#   for_each = local.database_connections
#   project  = var.project_id
#   name     = replace(google_service_account.default.email, ".gserviceaccount.com", "")
#   instance = each.key
#   type     = "CLOUD_IAM_SERVICE_ACCOUNT"
# 	database_roles = ["cloudsqlsuperuser"]
# }

/* Admin Credentials */
# resource "google_secret_manager_secret_iam_member" "default_admin_secret_accessor" {
#   project   = var.project_id
#   secret_id = google_secret_manager_secret.default_admin.secret_id
#   role      = "roles/secretmanager.secretAccessor"
#   member    = google_service_account.default.member
# }
# 
# resource "google_secret_manager_secret" "default_admin" {
#   project   = var.project_id
#   secret_id = "default-admin-credentials"
# 
#   replication {
#     auto {}
#   }
# }

/* === SonarQube Instance === */
resource "google_compute_instance" "default" {
  name         = var.name
  project      = var.project_id
  zone         = data.google_compute_zones.available.names[0]
  machine_type = var.machine_type

  tags = ["iap-ssh", var.name]

  boot_disk {
    initialize_params {
      image = "projects/debian-cloud/global/images/family/debian-12"
      size  = 30
      type  = "pd-balanced"
    }
  }

  network_interface {
    network            = var.network.name
    subnetwork         = var.subnetwork_name
    subnetwork_project = var.project_id
    # }
    access_config {
      /* Ephemeral public IP, required for downloading things */
    }
  }

  service_account {
    email  = google_service_account.default.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

	metadata_startup_script = <<-EOT
		# Make sure Docker is installed
		type docker || curl https://get.docker.com | bash

		# Sonarqube installation
		mkdir -p /opt/sonarqube
		cat <<-'DOCKER_COMPOSE' > /opt/sonarqube/docker-compose.yaml
		${yamlencode(local.docker_compose)}
		DOCKER_COMPOSE
		docker-compose -f /opt/sonarqube/docker-compose.yaml up -d 
	EOT
}

# --- Allow Traffic --- #
resource "google_compute_firewall" "default" {
	project = var.project_id
  name    = "${var.name}-ingress"
  network = var.network.name

  allow {
    protocol = "tcp"
    ports    = ["9000"]
  }

  direction     = "INGRESS"

	# TODO: Don't hard code GKE network ranges
  source_ranges = ["10.2.64.0/18", "10.2.128.0/20"]

  target_tags = [var.name]
}


/* === Developer IAM  Access === */

# resource "google_project_iam_custom_role" "set_instance_metadata" {
#   project     = var.project_id
#   role_id     = "DataSetInstanceMetadata"
#   title       = "Set Compute Instance Metadata"
#   description = "Allows updating metadata on Compute Engine instances"
#   permissions = [
#     "compute.instances.get",
#     "compute.instances.setMetadata",
#   ]
# }

# resource "google_project_iam_member" "set_instance_metadata" {
#   for_each = toset(var.developers)
#   project  = var.project_id
#   role     = google_project_iam_custom_role.set_instance_metadata.name
#   member   = each.value
# }

resource "google_project_iam_member" "os_login" {
  for_each = toset(var.developers)
  project  = var.project_id
  role     = "roles/compute.osLogin"
  member   = each.value
}

resource "google_project_iam_member" "os_admin_login" {
  for_each = toset(var.developers)
  project  = var.project_id
  role     = "roles/compute.osAdminLogin"
  member   = each.value
}

resource "google_project_iam_member" "iam_service_account_user" {
  for_each = toset(var.developers)
  project  = var.project_id
  role     = "roles/iam.serviceAccountUser"
  member   = each.value
}

resource "google_project_iam_member" "iap_tunnel_user" {
  for_each = toset(var.developers)
  project  = var.project_id
  role     = "roles/iap.tunnelResourceAccessor"
  member   = each.value
}

resource "google_project_iam_member" "compute_viewer" {
  for_each = toset(var.developers)
  project  = var.project_id
  role     = "roles/compute.viewer"
  member   = each.value
}

