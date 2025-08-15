locals {
  project_id = data.terraform_remote_state.core.outputs.project_id

  host = (
    var.sub_host == ""
  ) ? "${var.environment}.${var.host}" : "${var.sub_host}.${var.environment}.${var.host}"

  /* Application services is based on the YAML files in the values bucket */
  application_services = [
    for k, v in data.google_storage_bucket_objects.application_services.bucket_objects :
    replace(replace(v.name, "${var.environment}/${var.service_group}/", ""), ".yaml", "")
  ]

  application_service_values = {
    for i in local.application_services : i => yamldecode(
      data.google_storage_bucket_object_content.application_service_values[
        i
      ].content
    )
  }

  /* --- MySQL Services --- */
  mysql_services = [
    for k, v in local.application_service_values : k
    if contains(lookup(v, "requires", []), "mysql")
  ]

  /* --- RabbitMQ Services --- */
  rabbitmq_services = [
    for k, v in local.application_service_values : k
    if contains(lookup(v, "requires", []), "rabbitmq")
  ]

  /* --- Redis Services --- */
  redis_services = [
    for k, v in local.application_service_values : k
    if contains(lookup(v, "requires", []), "redis")
  ]

  /* --- Ingress Services --- */
  ingress_services = [
    for k, v in local.application_service_values : k
    if lookup(v, "ingress", false)
  ]

  certificates = [
    for service in local.ingress_services : "${var.service_group}-${service}"
  ]
}

