module "external-secrets" {
  source     = "../../external-secrets"
  project_id = local.project_id
}

/* === RabbitMQ Operater === */
resource "helm_release" "rabbitmq_cluster_operator" {
  name       = "rabbitmq-cluster-operator"
  chart      = "rabbitmq-cluster-operator"
  repository = "https://charts.bitnami.com/bitnami"
  namespace  = "rabbitmq"

  create_namespace = true
  # 15 Minute timeout, can take longer on intial cluster setup.
  timeout = 900

  values = [file(
    "${path.module}/../../../../helm/values/rabbitmq-cluster-operator.yaml"
  )]
}

#module "keycloak" {
#	source = "../../keycloak"
#	project_id = local.project_id
#	name = "keycloak"
#	host = "keycloak.${var.name}.roamtech.whitemire-technologies.com"
#	dns_managed_zone_project_id = var.management_project_id
#	dns_managed_zone_name = "root"
#	depends_on = [helm_release.environment_core]
#}

# resource "helm_release" "kafka" {
#   name       = "kafka"
#   chart      = "kafka"
# 	repository = "https://helm-charts.itboon.top/kafka"
# 	namespace = "kafka"
# 
# 	create_namespace = true
# 	# 15 Minute timeout, can take longer on intial cluster setup.
# 	timeout = 900
# }

# module "redis" {
# 	source = "../../redis"
# 	project_id = local.project_id
# 	users = ["paykit-core"]
# 	depends_on = [helm_release.environment_core]
# }

# module "application_service" {
# 	for_each = data.google_storage_bucket_object_content.application_service_values
# 	source = "../../application-service"
# 	project_id = local.project_id
# 	name = each.key
# 	tag = yamldecode(each.value.content).tag
# 	/* TODO: Use management outputs */
# 	gar = "${var.region}-docker.pkg.dev/${var.management_project_id}/docker"
# 	ingress = (lookup(yamldecode(each.value.content), "ingress", false)) ? {
#     host = "${each.key}.${var.name}.roamtech.whitemire-technologies.com"
# 		dns_managed_zone = {
# 			project_id = var.management_project_id
# 			name = "root"
# 		}
# 	} : null
# 	values = each.value.content
# 	depends_on = [
# 		resource.helm_release.kafka,
# 		module.redis
# 	]
# }

