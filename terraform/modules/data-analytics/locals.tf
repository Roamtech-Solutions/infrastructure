locals {
  airflow_roles = [
    "roles/bigquery.jobUser",
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/storage.objectViewer",
    "roles/storage.objectCreator",
    "roles/stackdriver.resourceMetadata.writer",
    "roles/cloudsql.client",
    "roles/cloudsql.instanceUser",
  ]
  analytics_buckets = {
    standard = {
      name          = "${var.project_id}-data-analytics-standard"
      storage_class = "STANDARD"
    }
    coldline = {
      name          = "${var.project_id}-data-analytics-coldline"
      storage_class = "COLDLINE"
    }
  }
  database_connections = {
    for i in data.google_sql_database_instances.all.instances : i.name => i.connection_name
    if(i.master_instance_name == "")
  }

  cloudsql_proxy_service_script = templatefile(
    "${path.module}/resources/cloudsql-proxy.service",
    {
      connections = local.database_connections
    }
  )
}

