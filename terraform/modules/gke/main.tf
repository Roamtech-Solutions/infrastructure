module "network" {
  source       = "terraform-google-modules/network/google"
  version      = "9.2.0"
  project_id   = var.project_id
  network_name = "gke-${var.name}"
  subnets = [
    {
      subnet_name           = "gke-${var.name}-private"
      subnet_ip             = "10.10.0.0/20"
      subnet_region         = var.region
      subnet_private_access = true
      subnet_flow_logs      = true
    }
  ]
  secondary_ranges = {
    "gke-${var.name}-private" = [
      {
        range_name    = "gke-${var.name}-private-pods"
        ip_cidr_range = local.pod_cidr
      },
      {
        range_name    = "gke-${var.name}-private-services"
        ip_cidr_range = local.svc_cidr
      },
    ]
  }
  shared_vpc_host = false
}

/* NAT for the cluster */
resource "google_compute_address" "nat" {
  count   = 2
  project = var.project_id
  name    = "gke-${var.name}-nat-${count.index}"
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
  nat_ips       = google_compute_address.nat[*].self_link
}

/* The Cluster */
module "gke" {
  source            = "terraform-google-modules/kubernetes-engine/google//modules/beta-autopilot-private-cluster"
  version           = "36.0.1"
  project_id        = var.project_id
  name              = var.name
  region            = var.region
  network           = module.network.network_name
  subnetwork        = "gke-${var.name}-private"
  ip_range_pods     = "gke-${var.name}-private-pods"
  ip_range_services = "gke-${var.name}-private-services"
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
  registry_project_ids    = var.registry_project_ids
  grant_registry_access   = true
  cluster_resource_labels = {}
  deletion_protection     = false
  depends_on              = [module.network]
}

/* IAM Permissions for connecting and deploying to the cluster */
resource "google_project_iam_member" "container_developer" {
  for_each = toset(var.cluster_developers)
  project  = var.project_id
  role     = "roles/container.developer"
  member   = each.value
}

/* Log viewing permissions */
resource "google_project_iam_member" "logging_viewer" {
  for_each = toset(var.cluster_developers)
  project  = var.project_id
  role     = "roles/logging.viewer"
  member   = each.value
}

/* Allow for private network access to CloudSQL */
module "private_service_access" {
  source      = "terraform-google-modules/sql-db/google//modules/private_service_access"
  version     = "26.1.1"
  project_id  = var.project_id
  vpc_network = module.network.network_name
}

