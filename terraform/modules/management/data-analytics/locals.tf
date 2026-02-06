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
}

