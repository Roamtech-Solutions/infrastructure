module "network_security" {
	source = "../../network-security"
	project_id = local.project_id
	allowed_networks = var.allowed_networks
}

module "gke" {
	source = "../../gke"
	name = var.name
	project_id = local.project_id
	registry_project_ids = [local.project_id, var.management_project_id]
	region = var.region
	allowed_networks = merge(
		var.allowed_networks,
		(var.gitlab_runner_ip != "") ? {
			gitlab_runner = "${var.gitlab_runner_ip}/32"
		} : {})
}

