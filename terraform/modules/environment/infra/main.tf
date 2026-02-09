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


/* === Testing MariDB === */
module "maridb" {
  source          = "../../mariadb"
  name            = "test"
  project_id      = local.project_id
  users           = ["wallet"]
  region          = var.region
  network_name    = module.gke.network.name
  subnetwork_name = values(module.gke.network.subnets)[0].name
}

