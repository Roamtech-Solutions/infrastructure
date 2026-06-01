module "network_security" {
  source     = "../../network-security"
  project_id = local.project_id
  allowed_networks = merge(
    {
      "vpn" = "${data.terraform_remote_state.management.outputs.vpn_address}/32"
    },
    var.allowed_networks
  )
}

module "gke" {
  source               = "../../gke"
  name                 = var.region
  project_id           = local.project_id
  registry_project_ids = [local.project_id, var.management_project_id]
  region               = var.region
  allowed_networks = merge(
    var.allowed_networks,
    {
      "vpn" = "${data.terraform_remote_state.management.outputs.vpn_address}/32"
    },
    {
      for idx, ip in data.terraform_remote_state.management.outputs.gha_cluster_nat_ips : "gha-cluster-${idx}" => "${ip}/32"
    },
    (var.ci_runner_ip != "") ? {
      ci_runner = "${var.ci_runner_ip}/32"
  } : {})
  jump_box_enabled = true
	# NOTE: Toggle to false on initial setup, then back to true to enable CloudSQL access
  enable_psa       = true
}

/* === Firewall Rules === */
resource "google_compute_firewall" "allow_iap_ssh" {
  project = local.project_id
  name    = "allow-iap-ssh"
  network = module.gke.network.name

  direction = "INGRESS"
  priority  = 1000

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["iap-ssh"]
}

module "iprs_network" {
  count        = (var.name == "production") ? 1 : 0
  source       = "terraform-google-modules/network/google"
  version      = "18.1.0"
  project_id   = local.project_id
  network_name = "iprs"
  subnets = [
    {
      subnet_name           = "iprs-${var.region}"
      subnet_ip             = "172.24.41.0/24"
      subnet_region         = var.region
      subnet_private_access = true
      subnet_flow_logs      = true
    },
  ]
  shared_vpc_host = false
}

module "ncc" {
  count        = (var.name == "production") ? 1 : 0
  source       = "terraform-google-modules/network/google//modules/network-connectivity-center"
  version      = "12.0.0"
  project_id   = local.project_id
  ncc_hub_name = var.region
  vpc_spokes = {
    "gke-${var.region}" = {
      uri                   = module.gke.network.id
      include_export_ranges = toset([module.gke.private_nat_cidr])
    }
    "iprs-${var.region}" = {
      uri = module.iprs_network[0].network_id
    }
  }
}

resource "google_compute_router_nat" "iprs_private_nat" {
  count                               = (var.name == "production") ? 1 : 0
  name                                = "iprs"
  router                              = module.gke.nat_router_name
  region                              = var.region
  source_subnetwork_ip_ranges_to_nat  = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  enable_dynamic_port_allocation      = true
  enable_endpoint_independent_mapping = false
  type                                = "PRIVATE"
  log_config {
    enable = false
    filter = "ALL"
  }
  rules {
    description = null
    match       = "nexthop.is_hybrid || nexthop.hub == '//networkconnectivity.googleapis.com/${module.ncc[0].ncc_hub.id}'"
    rule_number = 1000

    action {
      source_nat_active_ips = []
      source_nat_active_ranges = [
        "https://www.googleapis.com/compute/v1/projects/${local.project_id}/regions/${var.region}/subnetworks/${module.gke.private_nat_subnet}",
      ]
      source_nat_drain_ips    = []
      source_nat_drain_ranges = []
    }
  }
}

resource "google_compute_firewall" "iprs_allow_gke_private_nat" {
  count       = (var.name == "production") ? 1 : 0
  project     = local.project_id
  name        = "iprs-allow-gke-private-nat-ingress"
  network     = module.iprs_network[0].network_name
  description = "Allow ingress from the GKE private NAT"

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "9003", "9004"]
  }

  direction     = "INGRESS"
  source_ranges = [module.gke.private_nat_cidr]
}

resource "google_service_account" "iprs_proxy" {
  account_id   = "iprs-proxy"
  display_name = "iprs-proxy"
  project      = local.project_id
}

resource "google_compute_instance" "iprs_proxy" {
  count        = (var.name == "production") ? 1 : 0
  name         = "iprs-proxy"
  project      = local.project_id
  zone         = data.google_compute_zones.available.names[0]
  machine_type = "e2-small"

  tags = ["iap-ssh"]

  boot_disk {
    initialize_params {
      image = "projects/debian-cloud/global/images/family/debian-12"
      size  = 30
      type  = "pd-balanced"
    }
  }

  network_interface {
    network            = module.iprs_network[0].network_name
    subnetwork         = "iprs-${var.region}"
    subnetwork_project = local.project_id
    network_ip         = "172.24.41.9"
  }

  service_account {
    email  = google_service_account.iprs_proxy.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}

# === Sonarqube === #
module "sonarqube" {
  source          = "../../sonarqube"
  count           = (var.name == "production") ? 1 : 0
  project_id      = local.project_id
  region          = var.region
  developers      = var.developers
  network    = local.gke_network
  subnetwork_name = values(module.gke.network.subnets)[0].name
}

