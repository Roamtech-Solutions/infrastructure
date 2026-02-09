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

/* TODO: Restrict secret manager access to just the service group */
resource "google_project_iam_member" "external_secrets" {
  project = local.project_id
  role    = "roles/secretmanager.admin"
  member  = "serviceAccount:${google_service_account.external_secrets.email}"
}

/* === MySQL Database === */
module "cloudsql" {
  count            = length(local.mysql_services) > 0 ? 1 : 0
  source           = "../../cloudsql"
  project_id       = local.project_id
  name             = var.service_group
  database_version = "MYSQL_8_0"
  region           = var.region
  zone             = data.google_compute_zones.available.names[0]
  read_replica = (var.environment == "production") ? {
    region = var.secondary_region
    zone   = data.google_compute_zones.secondary.names[0]
  } : null
  network             = data.terraform_remote_state.infra.outputs.gke_network
  tier_primary        = var.mysql_tier
  users               = local.mysql_services
  deletion_protection = (var.environment == "production")
  database_flags      = var.mysql_database_flags
}

/* === PostgreSQL Database === */
module "postgresql" {
  count            = length(local.postgresql_services) > 0 ? 1 : 0
  source           = "../../cloudsql-pg"
  project_id       = local.project_id
  name             = var.service_group
  database_version = "POSTGRES_16"
  region           = var.region
  zone             = data.google_compute_zones.available.names[0]
  network          = data.terraform_remote_state.infra.outputs.gke_network
  tier_primary     = var.postgresql_tier
  users            = local.postgresql_services
}

/* === MariaDB === */
module "mariadb" {
  count           = length(local.mariadb_services) > 0 ? 1 : 0
  source          = "../../mariadb"
  project_id      = local.project_id
  name            = var.service_group
  region          = var.region
  network_name    = data.terraform_remote_state.infra.outputs.gke_network.name
  subnetwork_name = values(data.terraform_remote_state.infra.outputs.gke_subnets)[0].name
  users           = local.mariadb_services
}

/* === Service Group Setup === */

/* --- Ingress --- */
resource "google_compute_global_address" "default" {
  count   = (length(local.ingress_services) > 0) ? 1 : 0
  project = local.project_id
  name    = var.service_group
}

resource "google_dns_record_set" "default" {
  for_each = merge([
    for i in local.ingress_services : merge(
      {
        "${i.name}" = local.application_service_values[i.name]
      },
      {
        for ah in lookup(i, "additional_hosts", []) : "${ah}" => local.application_service_values[i.name]
      }
    ) if contains(keys(local.application_service_values), i.name)
    ]...
  )
  project = var.management_project_id
  /* Services called "website" assume the root of the host */
  name = (
    each.key == "website"
    ) ? "${local.host}." : (
    lookup(each.value, "custom_host", "") != ""
  ) ? "${each.value.custom_host}.${local.host}." : "${each.key}.${local.host}."
  managed_zone = replace(var.host, ".", "-")
  type         = "A"
  ttl          = "300"
  rrdatas      = [google_compute_global_address.default.0.address]
}

resource "google_dns_record_set" "keycloak" {
  count   = (local.keycloak_enabled) ? 1 : 0
  project = var.management_project_id
  /* Services called "website" assume the root of the host */
  name         = "keycloak.${local.host}."
  managed_zone = replace(var.host, ".", "-")
  type         = "A"
  ttl          = "300"
  rrdatas      = [google_compute_global_address.default.0.address]
}

resource "google_compute_security_policy" "default" {
  project = local.project_id
  name    = var.service_group
  type    = "CLOUD_ARMOR"

  /* Deny all by default */
  rule {
    action   = "deny(403)"
    priority = "2147483647"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "Default deny rule"
  }

  /* Allow specified networks */
  dynamic "rule" {
    for_each = (length(keys(local.allowed_networks)) > 0) ? ["0"] : []
    content {
      action   = "allow"
      priority = "2"
      match {
        versioned_expr = "SRC_IPS_V1"
        config {
          src_ip_ranges = [for k, v in local.allowed_networks : v]
        }
      }
      description = "Allow custom CIDR ranges"
    }
  }
}

resource "google_compute_security_policy" "public" {
  count   = length(local.public_services) > 0 ? 1 : 0
  project = local.project_id
  name    = "${var.service_group}-public"
  type    = "CLOUD_ARMOR"

  /* Allow all by default */
  rule {
    action   = "allow"
    priority = "2147483647"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "Default allow rule"
  }

  /* Allow specified networks */
  dynamic "rule" {
    for_each = (length(keys(local.allowed_networks)) > 0) ? ["0"] : []
    content {
      action   = "allow"
      priority = "2"
      match {
        versioned_expr = "SRC_IPS_V1"
        config {
          src_ip_ranges = [for k, v in local.allowed_networks : v]
        }
      }
      description = "Allow custom CIDR ranges"
    }
  }
}

resource "google_compute_security_policy" "restricted_services" {
  for_each = toset(local.restricted_services)
  project  = local.project_id
  name     = "${var.service_group}-${each.key}"
  type     = "CLOUD_ARMOR"

  /* Deny all by default */
  rule {
    action   = "deny(403)"
    priority = "2147483647"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "Default deny rule"
  }

  /* Allow specified networks */
  dynamic "rule" {
    for_each = (length(keys(local.allowed_networks)) > 0) ? ["0"] : []
    content {
      action   = "allow"
      priority = "2"
      match {
        versioned_expr = "SRC_IPS_V1"
        config {
          src_ip_ranges = [for k, v in local.allowed_networks : v]
        }
      }
      description = "Allow custom CIDR ranges"
    }
  }

  /* Allow service-specified networks */
  dynamic "rule" {
    for_each = local.application_service_values[each.key]["allowed_networks"]
    content {
      action   = "allow"
      priority = 3 + index(keys(local.application_service_values[each.key]["allowed_networks"]), rule.key)
      match {
        versioned_expr = "SRC_IPS_V1"
        config {
          src_ip_ranges = rule.value
        }
      }
      description = "Allow ${rule.key} CIDR ranges"
    }
  }
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
    region        = var.region
    name          = data.terraform_remote_state.infra.outputs.gke_cluster.name
    service_group = var.service_group
    rabbitmq = {
      enabled = (length(local.rabbitmq_services) > 0)
    }
    mysql_services      = local.mysql_services
    postgresql_services = local.postgresql_services
    ingress_services    = local.ingress_services
    kafka_services      = local.kafka_services
    certificates        = local.certificates
    host                = local.host
    pod_cidr            = data.terraform_remote_state.infra.outputs.gke_pod_cidr
    external_secrets_sa = google_service_account.external_secrets.email
  })]

  dependency_update = true

  depends_on = [module.cloudsql, module.postgresql]
}

/* === Redis === */
module "redis" {
  count      = (length(local.redis_services) > 0) ? 1 : 0
  source     = "../../redis"
  project_id = local.project_id
  users      = local.redis_services
  prefix     = var.service_group
  namespace  = var.service_group
  depends_on = [helm_release.service_group]
}

/* === Keycloak === */
module "keycloak" {
  count         = (length(local.keycloak_services) > 0) ? 1 : 0
  source        = "../../keycloak"
  project_id    = local.project_id
  service_group = var.service_group
  host          = "keycloak.${local.host}"
  depends_on    = [helm_release.service_group]
}

/* === Application Services === */
module "application_service" {
  for_each      = data.google_storage_bucket_object_content.application_service_values
  source        = "../../application-service"
  project_id    = local.project_id
  region        = var.region
  name          = each.key
  environment   = var.environment
  tag           = yamldecode(each.value.content).tag
  service_group = var.service_group
  host          = local.host

  /* TODO: Use management outputs */
  gar = "${var.region}-docker.pkg.dev/${var.management_project_id}/${var.service_group}"

  values = each.value.content
  depends_on = [
    resource.helm_release.service_group,
    module.redis,
    module.keycloak,
  ]
  developers = var.developers
}

/* === IAM Access === */

# IAM Permissions for connecting and deploying to the cluster
resource "google_project_iam_member" "container_developer" {
  for_each = toset(var.developers)
  project  = local.project_id
  role     = "roles/container.developer"
  member   = each.key
}

# Log viewing permissions
resource "google_project_iam_member" "logging_viewer" {
  for_each = toset(var.developers)
  project  = local.project_id
  role     = "roles/logging.viewer"
  member   = each.key
}


/* --- Instance Login --- */
# SSH via IAP
resource "google_project_iam_member" "ssh_iap" {
  for_each = toset(var.developers)
  project  = local.project_id
  role     = "roles/iap.tunnelResourceAccessor"
  member   = each.key
}

# OS Login
resource "google_project_iam_member" "compute_instance_admin" {
  for_each = toset(var.developers)
  project  = local.project_id
  role     = "roles/compute.instanceAdmin"
  member   = each.key
}

# Service Account User
resource "google_project_iam_member" "sa_user" {
  for_each = toset(var.developers)
  project  = local.project_id
  role     = "roles/iam.serviceAccountUser"
  member   = each.key
}

# Secrets Viewer
resource "google_project_iam_member" "secrets_viewer" {
  for_each = toset(var.developers)
  project  = local.project_id
  role     = "roles/secretmanager.viewer"
  member   = each.key
}

# Secrets Version Accessor
resource "google_project_iam_member" "secrets_version_accessor" {
  for_each = toset(var.developers)
  project  = local.project_id
  role     = "roles/secretmanager.secretAccessor"
  member   = each.key
}

# Secrets Version Adder
resource "google_project_iam_member" "secrets_version_adder" {
  for_each = toset(var.developers)
  project  = local.project_id
  role     = "roles/secretmanager.secretVersionAdder"
  member   = each.key
}

# CloudSQL Viewer
resource "google_project_iam_member" "cloudsql_viewer" {
  for_each = toset(var.developers)
  project  = local.project_id
  role     = "roles/cloudsql.viewer"
  member   = each.key
}

