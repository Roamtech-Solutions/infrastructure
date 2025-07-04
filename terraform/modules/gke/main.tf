module "network" {
  source       = "terraform-google-modules/network/google"
  version      = "9.2.0"
  project_id   = var.project_id
  network_name = var.name
  # Subnet per region, additional subnets are concatenated
  subnets = [
    for i, region in var.regions : {
      subnet_name           = "${region.name}-private"
      subnet_ip             = "10.10.${i * 16}.0/20"
      subnet_region         = region.name
      subnet_private_access = true
      subnet_flow_logs      = true
    }
  ]
  # Two secondary ranges per region, for each GKE cluster
  secondary_ranges = {
    for i, region in var.regions : "${region.name}-private" => [
      {
        range_name    = "${region.name}-private-pods"
        ip_cidr_range = "10.${length(var.regions) + i + 1}.64.0/18"
      },
      {
        range_name    = "${region.name}-private-services"
        ip_cidr_range = "10.${length(var.regions) + i + 1}.128.0/20"
      },
    ]
  }
  shared_vpc_host = false
}

module "gke" {
  for_each          = { for i, region in var.regions : region.name => i }
  source            = "terraform-google-modules/kubernetes-engine/google//modules/beta-autopilot-private-cluster"
  version           = "36.0.1"
  project_id        = var.project_id
  name              = "${var.name}-${each.key}"
  region            = each.key
  network           = module.network.network_name
  subnetwork        = "${each.key}-private"
  ip_range_pods     = "${each.key}-private-pods"
  ip_range_services = "${each.key}-private-services"
  release_channel   = "STABLE"

  horizontal_pod_autoscaling      = true
  enable_vertical_pod_autoscaling = true
  http_load_balancing             = true

  enable_private_nodes   = true
  master_ipv4_cidr_block = "10.${each.value}.0.0/28"
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

