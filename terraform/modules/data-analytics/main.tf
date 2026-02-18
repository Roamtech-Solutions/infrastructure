/* === Resources === */
resource "google_storage_bucket" "resources" {
  project                     = var.project_id
  name                        = "${var.project_id}-${var.name}-airflow-resources"
  force_destroy               = true
  location                    = var.region
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true
  versioning {
    enabled = true
  }
}

/* CloudSQL Proxy Service Script */
resource "google_storage_bucket_object" "cloudsql_proxy_service_script" {
  name           = "cloudsql-proxy.service"
  content        = local.cloudsql_proxy_service_script
  bucket         = google_storage_bucket.resources.name
  metadata       = {}
  source_md5hash = md5(local.cloudsql_proxy_service_script)
}

/* === Service Accounts & Related Permissions === */

/* --- Airflow --- */
resource "google_service_account" "airflow" {
  account_id   = "airflow"
  display_name = "Airflow"
  project      = var.project_id
}

resource "google_project_iam_member" "airflow_roles" {
  for_each = toset(local.airflow_roles)
  project  = var.project_id
  role     = each.value
  member   = google_service_account.airflow.member
}


/* CloudSQL Instances Access */
resource "google_project_iam_member" "airflow_cloudsql_client" {
  for_each = local.database_connections
  project  = var.project_id
  role     = "roles/cloudsql.client"
  member   = google_service_account.airflow.member
  condition {
    title = "OnlyThisInstance"
    #description = "Allow connecting only to one Cloud SQL instance"
    expression = "resource.name == 'projects/${var.project_id}/instances/${each.key}'"
  }
}

resource "google_sql_user" "airflow_iam_user" {
  for_each = local.database_connections
	project = var.project_id
	name = replace(google_service_account.airflow.email, ".gserviceaccount.com", "")
  instance = each.key
  type     = "CLOUD_IAM_SERVICE_ACCOUNT"
}

resource "google_secret_manager_secret_iam_member" "airflow_admin_secret_accessor" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.airflow_admin.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = google_service_account.airflow.member
}

resource "google_secret_manager_secret" "airflow_admin" {
  project   = var.project_id
  secret_id = "airflow-admin-credentials"

  replication {
    auto {}
  }
}

/* --- Metabase --- */
resource "google_service_account" "visualization_metabase_prod" {
  account_id   = "visualization-metabase-prod"
  display_name = "Visualization Metabase Prod"
  project      = var.project_id
}

resource "google_project_iam_member" "metabase_bigquery_job_user" {
  project = var.project_id
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.visualization_metabase_prod.email}"
}

/* === Buckets === **/
resource "google_storage_bucket" "analytics" {
  for_each = local.analytics_buckets

  name          = each.value.name
  project       = var.project_id
  location      = var.region
  storage_class = each.value.storage_class

  uniform_bucket_level_access = true

  labels = {
    env  = "prod"
    tier = each.key
  }
}

/* === Airflow Instance === */
resource "google_compute_instance" "airflow" {
  name         = "airflow"
  project      = var.project_id
  zone         = data.google_compute_zones.available.names[0]
  machine_type = "e2-standard-4"

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
    subnetwork         = var.subnetwork_name
    subnetwork_project = var.project_id
    access_config {
      /* Ephemeral public IP */
    }
  }

  service_account {
    email  = google_service_account.airflow.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  metadata_startup_script = templatefile(
    "${path.module}/resources/airflow-startup.sh",
    {
      resources_bucket = google_storage_bucket.resources.name
    }
  )
}

/* === User IAM === */

resource "google_project_iam_custom_role" "set_instance_metadata" {
  project     = var.project_id
  role_id     = "DataSetInstanceMetadata"
  title       = "Set Compute Instance Metadata"
  description = "Allows updating metadata on Compute Engine instances"
  permissions = [
    "compute.instances.get",
    "compute.instances.setMetadata",
  ]
}

resource "google_project_iam_member" "set_instance_metadata" {
  for_each = toset(var.developers)
  project  = var.project_id
  role     = google_project_iam_custom_role.set_instance_metadata.name
  member   = each.value
}

resource "google_project_iam_member" "bigquery_admin" {
  for_each = toset(var.developers)
  project  = var.project_id
  role     = "roles/bigquery.admin"
  member   = each.value
}

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

