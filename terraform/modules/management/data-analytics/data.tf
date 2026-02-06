/* === Available Zones in the Region === */
data "google_compute_zones" "available" {
  project = module.project.project_id
  region  = var.region
}
