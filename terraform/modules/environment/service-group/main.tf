/* === External secrets service account === */
resource "google_service_account" "external_secrets" {
  project      = local.project_id
  display_name = "${var.service_group} External Secrets SA"
  account_id   = "es-${var.service_group}"
}

resource "google_service_account_iam_member" "external_secrets" {
  service_account_id = google_service_account.external_secrets.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${local.project_id}.svc.id.goog[${var.service_group}/external-secrets]"
}

resource "google_project_iam_member" "external_secrets" {
  project = local.project_id
  role    = "roles/secretmanager.admin"
  member  = "serviceAccount:${google_service_account.external_secrets.email}"
}

/* === MySQL Database === */
module "cloudsql" {
	count = length(keys(local.mysql_services)) > 0 ? 1 : 0
  source           = "../../cloudsql"
  project_id       = local.project_id
  name             = var.service_group
  database_version = "MYSQL_8_0"
  region           = var.region
  zone             = data.google_compute_zones.available.names[0]
  network          = data.terraform_remote_state.infra.outputs.gke_network
  tier_primary     = "db-f1-micro"
}

/* --- Database Secrets & Connection Information --- */
/* A user and password is setup for each application service */
resource "random_password" "cloudsql" {
  for_each         = local.mysql_services
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "google_secret_manager_secret" "cloudsql" {
  for_each  = random_password.cloudsql
  project   = local.project_id
  secret_id = "${var.service_group}-cloudsql-${each.key}"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "cloudsql" {
  for_each = google_secret_manager_secret.cloudsql
  secret   = google_secret_manager_secret.cloudsql[each.key].id
  secret_data = jsonencode({
    host = module.cloudsql[0].private_ip_address
    port = 3306
    user = each.key
    pass = random_password.cloudsql[each.key].result
  })
}

/* === Service Group Setup === */

/* --- Ingress --- */
resource "google_compute_global_address" "default" {
  count = (length(keys(local.ingress_services)) > 0) ? 1 : 0
  project  = local.project_id
  name     = "${var.service_group}-${var.environment}"
}

resource "google_dns_record_set" "default" {
  count = length(google_compute_global_address.default)
  project      = var.management_project_id
  name         = "*.${local.host}."
  managed_zone = replace(var.host, ".", "-")
  type         = "A"
  ttl          = "300"
  rrdatas      = [google_compute_global_address.default.0.address]
}

/* --- Service Group Helm Chart --- */
resource "helm_release" "service_group" {
  name  = var.service_group
  chart = "${path.module}/../../../../helm/charts/service-group"

  namespace        = var.service_group
  create_namespace = true

  # 15 Minute timeout, can take longer on intial cluster setup.
  timeout = 900

  values = [yamlencode({
    projectId    = local.project_id
    region       = var.region
    name         = data.terraform_remote_state.infra.outputs.gke_cluster.name
    serviceGroup = var.service_group
    rabbitmq = {
      enabled = (length(keys(local.rabbitmq_services)) > 0)
    }
    cloudsqlServices = local.mysql_services
    podCidr                       = data.terraform_remote_state.infra.outputs.gke_pod_cidr
    externalSecretsServiceAccount = google_service_account.external_secrets.email
  })]
  dependency_update = true

  depends_on = [module.cloudsql, google_secret_manager_secret_version.cloudsql]
}

/* === Application Services === */
module "application_service" {
  for_each   = data.google_storage_bucket_object_content.application_service_values
  source     = "../../application-service"
  project_id = local.project_id

  name          = each.key
  tag           = yamldecode(each.value.content).tag
  service_group = var.service_group

  /* TODO: Use management outputs */
  gar = "${var.region}-docker.pkg.dev/${var.management_project_id}/${var.service_group}"

  values = each.value.content
  depends_on = [
    resource.helm_release.service_group,
  ]
}

