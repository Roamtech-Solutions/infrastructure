/* === Available Zones in the Region === */
data "google_compute_zones" "available" {
  project = var.project_id
  region  = var.region
}

/* SQL Instances */
data "google_sql_database_instances" "all" {
  project = var.project_id
}

