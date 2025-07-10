output "name" {
	value = module.gke.name
}

output "network" {
	value = {
		id = module.network.network_id
		name = module.network.network_name
		subnets = module.network.subnets
	}
}

