/* === Secret for Infrastructure Repository Pat === */
resource "google_secret_manager_secret" "infra_pat" {
  project   = var.project_id
  secret_id = "github-actions-infra-pat"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "infra_pat" {
  secret      = google_secret_manager_secret.infra_pat.id
  secret_data = "changeme"
}

resource "github_actions_secret" "infra-pat" {
	for_each = toset(local.repositories)
  repository       = each.key
  secret_name      = "INFRA_PAT"
  plaintext_value  = data.google_secret_manager_secret_version.infra_pat.secret_data
}

/* === Variables === */
resource "github_actions_variable" "service_name" {
 	for_each = data.github_repository.default
  repository          = each.value.name
  variable_name    = "SERVICE_NAME"
  value            = join(
		"-", slice(
			split(
				"-", each.value.name),
				1,
				length(
				split("-", each.value.name)
			)
		)
	)
}

resource "github_actions_variable" "service_group" {
 	for_each = data.github_repository.default
  repository          = each.value.name
  variable_name    = "SERVICE_GROUP"
  value            = split("-", each.value.name)[0]
}

/* === Workflows === */
resource "github_repository_file" "workflow_development" {
	for_each = data.github_repository.default
  repository          = each.value.name
  branch              = each.value.default_branch
  file                = ".github/workflows/development.yaml"
  content             = templatefile(
		"${path.module}/resources/development.yaml",
		{ github_organisation = var.github_organisation }
	)
  commit_message      = "Managed by Terraform"
  commit_author       = "Terraform"
  commit_email        = "terraform@${var.project_id}.iam.gserviceaccount.com"
  overwrite_on_create = true
	depends_on = [
		github_actions_variable.service_name,
		github_actions_variable.service_group,
	]
}

