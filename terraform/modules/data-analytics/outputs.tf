output "airflow_private_ip" {
 value = google_compute_instance.airflow.network_interface.0.network_ip
}

