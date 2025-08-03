output "docker_gars" {
  value = {
		for k, v in google_artifact_registry_repository.service_groups : k => {
			name     = v.name
			location = v.location
			project_id = module.project.project_id
		}
	}
}

output "dns_zones" {
	value = google_dns_managed_zone.default
}

