module "network" {
  source       = "terraform-google-modules/network/google"
  version      = "9.2.0"
  project_id   = var.project_id
  network_name = var.name
  subnets = [
    {
      subnet_name           = "${var.name}-private"
      subnet_ip             = "10.10.0.0/20"
      subnet_region         = var.region
      subnet_private_access = true
      subnet_flow_logs      = true
    }
  ]
  secondary_ranges = {
    "${var.name}-private" = [
      {
        range_name    = "${var.name}-private-pods"
        ip_cidr_range = "10.2.64.0/18"
      },
      {
        range_name    = "${var.name}-private-services"
        ip_cidr_range = "10.2.128.0/20"
      },
    ]
  }
  shared_vpc_host = false
}

resource "google_compute_address" "nat" {
	count = 2
  project = var.project_id
	name = "gke-${var.name}-nat-${count.index}"
  region  = var.region
}

module "nat" {
  source        = "terraform-google-modules/cloud-nat/google"
  version       = "5.3.0"
  project_id    = var.project_id
  region        = var.region
  network       = module.network.network_name
  create_router = true
  router        = "${module.network.network_name}-gke-nat-router"
	nat_ips = google_compute_address.nat[*].self_link
}

module "gke" {
  source            = "terraform-google-modules/kubernetes-engine/google//modules/beta-autopilot-private-cluster"
  version           = "36.0.1"
  project_id        = var.project_id
  name              = var.name
  region            = var.region
  network           = module.network.network_name
  subnetwork        = "${var.name}-private"
  ip_range_pods     = "${var.name}-private-pods"
  ip_range_services = "${var.name}-private-services"
  release_channel   = "STABLE"

  horizontal_pod_autoscaling      = true
  enable_vertical_pod_autoscaling = true
  http_load_balancing             = true

  enable_private_nodes   = true
  master_ipv4_cidr_block = "10.0.0.0/28"
  master_authorized_networks = [
    for k, v in var.allowed_networks : {
      display_name = k
      cidr_block   = v
    }
  ]

  create_service_account  = true
  registry_project_ids    = [var.gar_project_id]
  grant_registry_access   = true
  cluster_resource_labels = {}
  deletion_protection     = false
}

# IAM Permissions for connecting and deploying to the cluster
resource "google_project_iam_member" "container_developer" {
  for_each = toset(var.cluster_developers)
  project  = var.project_id
  role     = "roles/container.developer"
  member   = each.value
}

# Log viewing permissions
resource "google_project_iam_member" "logging_viewer" {
  for_each = toset(var.cluster_developers)
  project  = var.project_id
  role     = "roles/logging.viewer"
  member   = each.value
}

# Docker GAR
resource "google_artifact_registry_repository" "docker" {
  project                = var.gar_project_id
  location               = var.gar_region
  repository_id          = "${var.name}-docker"
  description            = "${var.name} Docker Repository"
  format                 = "DOCKER"
  cleanup_policy_dry_run = false
  docker_config {
    immutable_tags = true
  }
  vulnerability_scanning_config {
    enablement_config = "INHERITED"
  }
}

# Helm GAR
resource "google_artifact_registry_repository" "helm" {
  project                = var.gar_project_id
  location               = var.gar_region
  repository_id          = "${var.name}-helm"
  description            = "${var.name} Helm Chart Repository"
  format                 = "DOCKER"
  cleanup_policy_dry_run = false
  docker_config {
    immutable_tags = true
  }
  vulnerability_scanning_config {
    enablement_config = "INHERITED"
  }
}

