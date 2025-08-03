resource "google_iam_workload_identity_pool" "default" {
  project                   = var.project_id
  workload_identity_pool_id = "github"
  display_name              = "GitHub"
  description               = "Identity pool for GitHub actions "
}

# Provider is setup to work with the Google auth GitHub action with direct
# workload identity federation:
# https://github.com/google-github-actions/auth?tab=readme-ov-file#preferred-direct-workload-identity-federation
resource "google_iam_workload_identity_pool_provider" "default" {
  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.default.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider"
  display_name                       = "GitHub"
  attribute_condition                = "assertion.repository_owner == '${var.github_organisation}'"
  attribute_mapping = {
    "google.subject"             = "assertion.sub"
    "attribute.actor"            = "assertion.actor"
    "attribute.repository"       = "assertion.repository"
    "attribute.repository_owner" = "assertion.repository_owner"
  }
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

