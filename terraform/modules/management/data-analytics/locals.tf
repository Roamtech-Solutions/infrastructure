locals {
  airflow_roles = [
    "roles/bigquery.jobUser",
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/storage.objectViewer",
    "roles/storage.objectCreator",
    "roles/stackdriver.resourceMetadata.writer",
  ]
  analytics_buckets = {
    standard = {
      name          = "roamtech-data-analytics-prod-standard"
      storage_class = "STANDARD"
    }
    coldline = {
      name          = "roamtech-data-analytics-prod-coldline"
      storage_class = "COLDLINE"
    }
  }
	database_connections = {
		for connection in var.database_connections : connection => {
			project_id = split(":", connection)[0]
			region = split(":", connection)[1]
			name = split(":", connection)[2]
		}
	}
	database_connection_projects = distinct([
		for connection in var.database_connections : split(":", connection)[0]
	])
	cloudsql_proxy_service_script = templatefile(
		"${path.module}/resources/cloudsql-proxy.service",
		{
			connections = var.database_connections
		}
	)
}

