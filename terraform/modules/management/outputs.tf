output "workload_identity_pool_provider_name" {
   value = module.gitlab_oidc.workload_identity_pool_provider_name
}

output "gitlab_ci_sa_email" {
	value = google_service_account.gitlab_ci.email
}

