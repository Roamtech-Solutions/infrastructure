locals {
  project_id = data.terraform_remote_state.core.outputs.project_id
	gke_network = {
    id   = module.gke.network.id
    name = module.gke.network.name
  }
}

