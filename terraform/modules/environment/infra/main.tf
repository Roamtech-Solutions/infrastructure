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
  name                 = var.name
  project_id           = local.project_id
  registry_project_ids = [local.project_id, var.management_project_id]
  region               = var.region
  allowed_networks = merge(
    var.allowed_networks,
    {
      "vpn" = "${data.terraform_remote_state.management.outputs.vpn_address}/32"
    },
    (var.ci_runner_ip != "") ? {
      ci_runner = "${var.ci_runner_ip}/32"
  } : {})
}

