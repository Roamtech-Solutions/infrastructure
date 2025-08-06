locals {
  project_id = data.terraform_remote_state.core.outputs.project_id

  /* Application services is based on the YAML files in the values bucket */
  application_services = [
    for k, v in data.google_storage_bucket_objects.application_services.bucket_objects :
    replace(
      replace(v.name, "${var.environment}/${var.service_group}/", ""), ".yaml", ""
    )
  ]

  application_service_values = {
    for i in local.application_services : i => yamldecode(
      data.google_storage_bucket_object_content.application_service_values[
        i
      ].content
    )
  }

  /* Application services which have a mysql property */
  mysql_services = {
    for k, v in local.application_service_values : k => lookup(v, "mysql", {})
    if lookup(v, "mysql", {}) != {}
  }

  /* Application services which have a rabbitmq property */
  rabbitmq_services = {
    for k, v in local.application_service_values : k => lookup(v, "rabbitmq", {})
    if lookup(v, "rabbitmq", {}) != {}
  }

	/* Ingress services */
  ingress_services = {
    for k, v in local.application_service_values : k => merge(
			lookup( v, "ingress", {}),
			{ port = v.port }
		) if lookup(v, "ingress", {}) != {}
	}
}

