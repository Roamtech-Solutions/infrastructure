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
  version      = "9.2.0"
  project_id   = local.project_id
  network_name = "iprs"
  subnets = [
    {
      subnet_name           = "iprs-${var.region}"
      subnet_ip             = "172.24.41.0/24"
      subnet_region         = var.region
      subnet_private_access = true
      subnet_flow_logs      = true
    }
  ]
  shared_vpc_host = false
}

# resource "google_compute_network_peering" "iprs_peering_1" {
#   count        = (var.name == "production") ? 1 : 0
#   name         = "iprs-to-gke"
#   network      = module.iprs_network[0].network_self_link
#   peer_network = module.gke.network_self_link
# }
# 
# resource "google_compute_network_peering" "iprs_peering_2" {
#   count        = (var.name == "production") ? 1 : 0
#   name         = "gke-to-iprs"
#   network      = module.gke.network_self_link
#   peer_network = module.iprs_network[0].network_self_link
# }

