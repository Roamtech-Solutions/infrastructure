output "docker_gars" {
  value = {
    for k, v in google_artifact_registry_repository.service_groups : k => {
      name       = v.name
      location   = v.location
      project_id = module.project.project_id
    }
  }
}

output "dns_zones" {
  value = google_dns_managed_zone.default
}

/* The CI member that will be able to control environment projects */
output "ci_iam_member" {
  value = module.github_oidc.principal_set
}

output "vpn_address" {
  value = module.vpn.address
}

output "gh_actions_cluster" {
  value = {
    name   = module.gke_gh_actions.name
    region = var.region
  }
}

output "gh_org" {
	value = var.github_organisation
}
