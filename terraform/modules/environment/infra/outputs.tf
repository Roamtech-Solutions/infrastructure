output "gke_cluster" {
  value = {
    name   = module.gke.name
    region = var.region
  }
}

output "gke_network" {
  value = {
    id   = module.gke.network.id
    name = module.gke.network.name
  }
}

output "gke_subnets" {
	value = module.gke.network.subnets
}

output "gke_pod_cidr" {
  value = module.gke.pod_cidr
}

output "gke_svc_cidr" {
  value = module.gke.svc_cidr
}

