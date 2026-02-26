output "name" {
  value = module.gke.name
}

output "network" {
  value = {
    id      = module.network.network_id
    name    = module.network.network_name
    subnets = module.network.subnets
  }
}

output "nat_router_name" {
	value = module.nat.router_name
}

output "private_nat_subnet" {
      value           = "gke-nat-${var.region}"
}

output "private_nat_cidr" {
	value = local.private_nat_cidr
}

output "network_self_link" {
  value = module.network.network_self_link
}

output "nat_ips" {
  value = google_compute_address.nat[*].address
}

output "pod_cidr" {
  value = local.pod_cidr
}

output "svc_cidr" {
  value = local.svc_cidr
}

