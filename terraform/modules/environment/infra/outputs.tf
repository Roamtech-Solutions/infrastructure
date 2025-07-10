output "gke_cluster" {
		value = {
			name = module.gke.name
			region = var.region
		}
}

