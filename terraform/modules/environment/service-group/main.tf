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

/*TODO: Restrict secret manager access to just the service group */
resource "google_project_iam_member" "external_secrets" {
  project = local.project_id
  role    = "roles/secretmanager.admin"
  member  = "serviceAccount:${google_service_account.external_secrets.email}"
}

/* === MySQL Database === */
module "cloudsql" {
	count = length(local.mysql_services) > 0 ? 1 : 0
  source           = "../../cloudsql"
  project_id       = local.project_id
  name             = var.service_group
  database_version = "MYSQL_8_0"
  region           = var.region
  zone             = data.google_compute_zones.available.names[0]
  network          = data.terraform_remote_state.infra.outputs.gke_network
  tier_primary     = "db-f1-micro"
	users = local.mysql_services
}


/* === Service Group Setup === */

/* --- Ingress --- */
resource "google_compute_global_address" "default" {
  count = (length(local.ingress_services) > 0) ? 1 : 0
  project  = local.project_id
  name     = var.service_group
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
    project_id    = local.project_id
    region       = var.region
    name         = data.terraform_remote_state.infra.outputs.gke_cluster.name
    service_group = var.service_group
    rabbitmq = {
      enabled = (length(local.rabbitmq_services) > 0)
    }
    mysql_services = local.mysql_services
		ingress_services = local.ingress_services
		certificates = local.certificates
		host = local.host
    pod_cidr                       = data.terraform_remote_state.infra.outputs.gke_pod_cidr
    external_secrets_sa = google_service_account.external_secrets.email
  })]

  dependency_update = true

  depends_on = [module.cloudsql]
}

/* === Redis === */
module "redis" {
	count = (length(local.redis_services) > 0) ? 1 : 0
	source = "../../redis"
	project_id = local.project_id
	users = local.redis_services
	prefix = var.service_group
	namespace = var.service_group
	depends_on = [helm_release.service_group]
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

