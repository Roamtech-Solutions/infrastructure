data "google_compute_zones" "available" {
  count   = length(var.regions)
  project = module.project.project_id
  region  = var.regions[count.index]
}

data "google_client_config" "default" {}

data "google_container_cluster" "primary" {
	project = module.project.project_id
  name     = "${var.name}-${var.regions[0]}"
  location = var.regions[0]
}

# Configure the Kubernetes provider to interact with the GKE cluster
provider "kubernetes" {
  host                   = "https://${data.google_container_cluster.primary.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(data.google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
}

# Configure the Helm provider
provider "helm" {
  kubernetes = {
    host                   = "https://${data.google_container_cluster.primary.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(data.google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
  }
}

