locals {
  project_id = data.terraform_remote_state.core.outputs.project_id

  environment_name = (var.custom_environment_name == "") ? var.environment : var.custom_environment_name

  /* --- Host Name --- */
  base_host = (
    var.environment == "production"
  ) ? "${var.host}" : "${local.environment_name}.${var.host}"
  host = (
    var.sub_host == ""
  ) ? local.base_host : "${var.sub_host}.${local.base_host}"


  allowed_networks = merge(
    var.allowed_networks,
    {
      "vpn" = "${data.terraform_remote_state.management.outputs.vpn_address}/32"
      "bob" = "80.71.4.141/32"
    }
  )

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

  /* --- Restricted Services --- */
  restricted_services = [
    for k, v in local.application_service_values : k
    if length(lookup(v, "allowed_networks", [])) > 0
  ]

  /* --- Public Services --- */
  public_services = [
    for k, v in local.application_service_values : k
    if lookup(v, "public", false)
  ]

  /* --- Keycloak Services --- */
  keycloak_services = [
    for k, v in local.application_service_values : k
    if contains(lookup(v, "requires", []), "keycloak")
  ]
  keycloak_enabled = length(local.keycloak_services) > 0

  /* --- MySQL Services --- */
  sg_mysql_services = [
    for k, v in local.application_service_values : k
    if contains(lookup(v, "requires", []), "mysql") || v.type == "wordpress"
  ]
  mysql_services = concat(
    local.sg_mysql_services,
    (length(local.sg_mysql_services) > 0) ? ["metabase"] : []
  )

  /* --- PostgreSQL Services --- */
  postgresql_services = distinct(concat(
    [
      for k, v in local.application_service_values : k
      if contains(lookup(v, "requires", []), "postgresql")
    ],
    (local.keycloak_enabled) ? ["keycloak"] : []
  ))

  /* --- MariaDB Services --- */
  mariadb_services = concat([
    for k, v in local.application_service_values : k
    if contains(lookup(v, "requires", []), "mariadb")
  ])

  /* --- MongoDB Services --- */
  mongodb_services = concat([
    for k, v in local.application_service_values : k
    if contains(lookup(v, "requires", []), "mongodb")
  ])

  /* --- RabbitMQ Services --- */
  rabbitmq_services = [
    for k, v in local.application_service_values : k
    if contains(lookup(v, "requires", []), "rabbitmq")
  ]
  rabbitmq_enabled = length(local.rabbitmq_services) > 0

  /* --- Redis Services --- */
  redis_services = [
    for k, v in local.application_service_values : k
    if contains(lookup(v, "requires", []), "redis")
  ]

  /* --- Ingress Services --- */
  ingress_services = distinct(concat(
    /* Service port defaulted to 8080 */
    [
      for k, v in local.application_service_values : {
        name             = k,
        port             = lookup(v, "port", 8080),
        custom_host      = lookup(v, "custom_host", ""),
        additional_hosts = lookup(v, "additional_hosts", []),
      }
      if lookup(v, "ingress", false)
    ],
    (local.keycloak_enabled) ? [{
      name             = "keycloak",
      port             = 8080
      custom_host      = "",
      additional_hosts = [],
    }] : [],
    /* RabbitMQ Ingress */
    (local.rabbitmq_enabled) ? [{
      name             = "rabbitmq",
      port             = 15672
      custom_host      = "",
      additional_hosts = [],
    }] : []
  ))

  /* --- Kafka Services --- */
  kafka_services = [
    for k, v in local.application_service_values : k
    if contains(lookup(v, "requires", []), "kafka")
  ]

  certificates = [
    for s in local.ingress_services : "${var.service_group}-${s.name}"
  ]
}

