resource "helm_release" "application_service" {
	name = var.name
  chart      = "${path.module}/../../../helm/charts/application-service"
	namespace = var.service_group
	create_namespace = true
	values = [
		yamlencode({
			image =  "${var.gar}/${var.name}:${var.tag}"
			host = (var.ingress != null) ? var.ingress.host : ""
			serviceGroup = var.service_group
		}),
		var.values,
	]
}

/* Ingress */
resource "google_compute_global_address" "default" {
	for_each = local.ingress
  project = var.project_id
  name    = "${var.service_group}-${var.name}"
}

resource "google_dns_record_set" "default" {
	for_each = local.ingress
  project      = each.value.dns_managed_zone.project_id
  name         = "${each.value.host}."
 	managed_zone = each.value.dns_managed_zone.name
  type         = "A"
  ttl          = "300"
  rrdatas      = [google_compute_global_address.default.0.address]
}

/* === Secrets === */
# resource "google_secret_manager_secret" "empty" {
# 	for_each = local.secrets_empty
# 	project = var.project_id
# 	secret_id = each.key
#   replication {
#     auto {}
#   }
# }
# 
# resource "google_secret_manager_secret" "generated" {
# 	for_each = local.secrets_generated
# 	project = var.project_id
# 	secret_id = each.key
#   replication {
#     auto {}
#   }
# }
# 
# resource "random_password" "generated" {
# 	for_each = local.secrets_generated
#   length           = lookup(each.value, "length", 16)
#   special          = lookup(each.value, "special", true)
#   override_special = "!#$%&*()-_=+[]{}<>:?"
# }
# 
# resource "google_secret_manager_secret_version" "generated" {
# 	for_each = google_secret_manager_secret.generated
#   secret      = each.value.id
#   secret_data = random_password.generated[each.key]
# }
# 
# /* MySQL root password */
# resource "random_password" "mysql_root" {
# 	count = (local.mysql) ? 1 : 0
#   length           = 16
#   special          = true
#   override_special = "!#$%&*()-_=+[]{}<>:?"
# }
# 
# resource "google_secret_manager_secret" "mysql_root" {
# 	count = (local.mysql) ? 1 : 0
#   project   = var.project_id
#   secret_id = "${var.name}-mysql-root-password"
#   replication {
#     auto {}
#   }
# }
# 
# resource "google_secret_manager_secret_version" "mysql_root" {
# 	count = (local.mysql) ? 1 : 0
#   secret      = google_secret_manager_secret.mysql_root[0].id
#   secret_data = random_password.mysql_root[0].result
# }

