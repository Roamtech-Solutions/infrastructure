/* TODO: Rename module to external_secrets */
module "external-secrets" {
  source     = "../../external-secrets"
  project_id = var.project_id
}

resource "helm_release" "arc" {
  name             = "arc"
  chart            = "oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set-controller"
  namespace        = "arc-systems"
  create_namespace = true
}

/* --- External secrets service account --- */
resource "google_service_account" "gh_actions_external_secrets" {
  project      = var.project_id
  display_name = "GitHub Actions External Secrets SA"
  account_id   = "es-gh-actions"
}

resource "google_service_account_iam_member" "gh_actions_external_secrets" {
  service_account_id = google_service_account.gh_actions_external_secrets.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${local.gh_actions_runner_namespace}/external-secrets]"
}

/* TODO: Restrict secret manager access to just the service group */
resource "google_project_iam_member" "external_secrets" {
  project = var.project_id
  role    = "roles/secretmanager.admin"
  member  = "serviceAccount:${google_service_account.gh_actions_external_secrets.email}"
}


resource "helm_release" "gha_runner_secrets" {
  name  = "gha-runner-secrets"
  chart = "${path.module}/../../../../helm/charts/gha-runner-secrets"

  namespace        = local.gh_actions_runner_namespace
  create_namespace = true

  values = [yamlencode({
    project_id    = var.project_id
    region        = data.terraform_remote_state.core.outputs.gh_actions_cluster.region
		cluster_name = data.terraform_remote_state.core.outputs.gh_actions_cluster.name
    external_secrets_sa = google_service_account.gh_actions_external_secrets.email
  })]
}

resource "helm_release" "gha_arc_runner_set" {
  name             = "arc-runner-set"
  chart            = "oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set"
  namespace        = local.gh_actions_runner_namespace
  create_namespace = true
  values = [yamlencode({
    project_id    = var.project_id
    githubConfigUrl = "https://github.com/organizations/${data.terraform_remote_state.core.outputs.gh_org}"
		githubConfigSecret = "github-config-secret"
  })]
  depends_on = [module.external-secrets, helm_release.arc, helm_release.gha_runner_secrets]
}
