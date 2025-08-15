data "github_repositories" "default" {
  query           = "org:${var.github_organisation}"
  include_repo_id = true
}

data "github_repository" "default" {
  for_each = toset([
    for full_name in data.github_repositories.default.full_names : full_name
    if full_name != "${var.github_organisation}/infrastructure"
  ])
  full_name = each.key
}

data "google_secret_manager_secret_version" "infra_pat" {
  secret     = google_secret_manager_secret.infra_pat.id
  depends_on = [google_secret_manager_secret_version.infra_pat]
}

