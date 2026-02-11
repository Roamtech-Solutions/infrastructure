module "project" {
  source            = "terraform-google-modules/project-factory/google"
  version           = "18.0.0"
  name              = var.name
  random_project_id = true
  org_id            = var.organisation
  billing_account   = var.billing_account

  deletion_policy = "DELETE"

  /* Services */
  activate_apis               = var.services
  disable_services_on_destroy = false
  disable_dependent_services  = false

  labels = {
    env = var.name
  }
}

module "network" {
  source       = "terraform-google-modules/network/google"
  version      = "9.2.0"
  project_id   = module.project.project_id
  network_name = var.name
  subnets = [
    {
      subnet_name           = "${var.region}-${var.name}"
      subnet_ip             = "10.128.0.0/24"
      subnet_region         = var.region
      subnet_private_access = true
      subnet_flow_logs      = true
    }
  ]
  shared_vpc_host = false
}

/* Allow for private network access to CloudSQL */
module "private_service_access" {
  source      = "terraform-google-modules/sql-db/google//modules/private_service_access"
  version     = "26.1.1"
  project_id  = module.project.project_id
  vpc_network = module.network.network_name
  # depends_on  = [module.network]
}

/* === Resources === */
resource "google_storage_bucket" "resources" {
  project                     = module.project.project_id
  name                        = "${module.project.project_id}-${var.name}-airflow-resources"
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
  name     = "cloudsql-proxy.service"
  content   = local.cloudsql_proxy_service_script
  bucket   = google_storage_bucket.resources.name
  metadata = {}
	source_md5hash = md5(local.cloudsql_proxy_service_script)
}

/* === Service Accounts & Related Permissions === */

/* --- Airflow --- */
resource "google_service_account" "data_pipelines_airflow_prod" {
  account_id   = "data-pipelines-airflow-prod"
  display_name = "Data Pipelines Airflow Prod"
  project      = module.project.project_id
}

resource "google_project_iam_member" "airflow_roles" {
  for_each = toset(local.airflow_roles)
  project  = module.project.project_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.data_pipelines_airflow_prod.email}"
}


/* CloudSQL Instances Access */
resource "google_project_iam_member" "airflow_cloudsql_client" {
  for_each = local.database_connections
  project  = each.value.project_id
  role     = "roles/cloudsql.client"
	member = google_service_account.data_pipelines_airflow_prod.member
	condition {
    title       = "OnlyThisInstance"
    #description = "Allow connecting only to one Cloud SQL instance"
    expression  = "resource.name == 'projects/${each.value.project_id}/instances/${each.value.name}'"
  }
}

resource "google_project_iam_member" "airflow_cloudsql_instance_user" {
  for_each = toset(local.database_connection_projects)
  project  = each.value
  role     = "roles/cloudsql.instanceUser"
	member = google_service_account.data_pipelines_airflow_prod.member
}

resource "google_secret_manager_secret_iam_member" "airflow_admin_secret_accessor" {
  project   = module.project.project_id
  secret_id = google_secret_manager_secret.airflow_admin.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.data_pipelines_airflow_prod.email}"
}

resource "google_secret_manager_secret" "airflow_admin" {
  project   = module.project.project_id
  secret_id = "airflow-admin-credentials"

  replication {
    auto {}
  }
}

/* --- Metabase --- */
resource "google_service_account" "visualization_metabase_prod" {
  account_id   = "visualization-metabase-prod"
  display_name = "Visualization Metabase Prod"
  project      = module.project.project_id
}

resource "google_project_iam_member" "metabase_bigquery_job_user" {
  project = module.project.project_id
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.visualization_metabase_prod.email}"
}

/* === Buckets === **/
resource "google_storage_bucket" "analytics" {
  for_each = local.analytics_buckets

  name          = each.value.name
  project       = module.project.project_id
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
  project      = module.project.project_id
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
    network            = module.network.network_name
    subnetwork         = "${var.region}-${var.name}"
    subnetwork_project = module.project.project_id
    access_config {
      /* Ephemeral public IP */
    }
  }

  service_account {
    email  = google_service_account.data_pipelines_airflow_prod.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  metadata_startup_script = templatefile(
		"${path.module}/resources/airflow-startup.sh",
		{
			resources_bucket = google_storage_bucket.resources.name
		}
	)
}

/* === Firewall Rules === */
resource "google_compute_firewall" "allow_iap_ssh" {
  project = module.project.project_id
  name    = "allow-iap-ssh"
  network = module.network.network_name

  direction = "INGRESS"
  priority  = 1000

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["iap-ssh"]
}

/* === User IAM === */

resource "google_project_iam_custom_role" "set_instance_metadata" {
  project     = module.project.project_id
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
  project  = module.project.project_id
  role     = google_project_iam_custom_role.set_instance_metadata.name
  member   = each.value
}

resource "google_project_iam_member" "bigquery_admin" {
  for_each = toset(var.developers)
  project  = module.project.project_id
  role     = "roles/bigquery.admin"
  member   = each.value
}

resource "google_project_iam_member" "os_login" {
  for_each = toset(var.developers)
  project  = module.project.project_id
  role     = "roles/compute.osLogin"
  member   = each.value
}

resource "google_project_iam_member" "os_admin_login" {
  for_each = toset(var.developers)
  project  = module.project.project_id
  role     = "roles/compute.osAdminLogin"
  member   = each.value
}

resource "google_project_iam_member" "iam_service_account_user" {
  for_each = toset(var.developers)
  project  = module.project.project_id
  role     = "roles/iam.serviceAccountUser"
  member   = each.value
}

resource "google_project_iam_member" "iap_tunnel_user" {
  for_each = toset(var.developers)
  project = module.project.project_id
  role    = "roles/iap.tunnelResourceAccessor"
  member  = each.value
}

