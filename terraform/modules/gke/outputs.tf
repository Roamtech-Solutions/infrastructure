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

// output "external_secrets_sa" {
//   value = google_service_account.external_secrets
// }

