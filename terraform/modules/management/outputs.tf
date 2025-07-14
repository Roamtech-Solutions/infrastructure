/* TODO: Provider names are going to be needed for setting up GitLab pipelines */
# output "workload_identity_pool_provider_name" {
#   value = module.gitlab_oidc.workload_identity_pool_provider_name
# }

output "gitlab_ci_sa_member" {
  value = module.gitlab_oidc.service_account_member
}

output "docker_gar" {
  value = {
    name     = google_artifact_registry_repository.docker.name
    location = google_artifact_registry_repository.docker.location
		project_id = module.project.project_id
  }
}

