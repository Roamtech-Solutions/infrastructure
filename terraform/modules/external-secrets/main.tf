/* External Secrets */
resource "helm_release" "external_secrets" {
  name       = "external-secrets"
  chart      = "external-secrets"
  repository = "https://charts.external-secrets.io"
  namespace  = "external-secrets"

  create_namespace = true
  # 15 Minute timeout, can take longer on intial cluster setup.
  timeout = 900

  values = [file("${path.module}/../../../helm/values/external-secrets.yaml")]
  set = [

    {
      name  = "serviceAccount.annotations.iam\\.gke\\.io\\/gcp-service-account"
      value = "${google_service_account.default.email}"
    }
  ]
}

/*
	Workload Identity and permissions for managing and accessing secrets.
	This is required by the external secrets operator for propagating secret
	values to the cluster and pushing secrets to secret manager.
*/
resource "google_service_account" "default" {
  project      = var.project_id
  display_name = "External Secrets"
  account_id   = "external-secrets"
}

resource "google_service_account_iam_member" "default" {
  service_account_id = google_service_account.default.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[external-secrets/external-secrets]"
}

/* TODO: Restrict token creator access to just the external secrets service 
 * 			 accounts.
 */
resource "google_project_iam_member" "service_account_token_creator" {
  project = var.project_id
  role    = "roles/iam.serviceAccountTokenCreator"
  member  = "serviceAccount:${google_service_account.default.email}"
}

