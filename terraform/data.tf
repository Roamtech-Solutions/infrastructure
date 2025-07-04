data "google_compute_zones" "available" {
  count   = length(var.regions)
  project = module.project.project_id
  region  = var.regions[count.index]
}

