output "docker_gar" {
  value = {
    name     = google_artifact_registry_repository.docker.name
    location = google_artifact_registry_repository.docker.location
		project_id = module.project.project_id
  }
}

output "dns_zones" {
	value = google_dns_managed_zone.default
}

