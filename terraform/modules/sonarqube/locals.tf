locals {
  default_roles = [
    "roles/monitoring.metricWriter",
    "roles/storage.objectViewer",
    "roles/storage.objectCreator",
    "roles/stackdriver.resourceMetadata.writer",
    "roles/cloudsql.client",
    "roles/cloudsql.instanceUser",
  ]

	database_connection = ""

	docker_compose = {
		services = {
		  sonarqube = {
		    image = "sonarqube:enterprise"
		    network_mode = "host"
		    read_only = true
		    # environment =
		      # SONAR_JDBC_URL = jdbc =postgresql =//db =5432/sonar
		      # SONAR_JDBC_USERNAME = sonar
		      # SONAR_JDBC_PASSWORD = sonar
		    volumes = [
					"sonarqube_data:/opt/sonarqube/data",
					"sonarqube_logs:/opt/sonarqube/logs",
					"sonarqube_temp:/opt/sonarqube/temp",
				]
		    tmpfs = [
		     	"/tmp:size=256M,mode=1777",
				]
			}
      cloudsql-proxy = {
        network_mode = "host"
        image = "gcr.io/cloud-sql-connectors/cloud-sql-proxy:2.22.0"
        command = "--address 0.0.0.0 --port 3306 --private-ip ${local.database_connection}"
			}
		}
		volumes = {
			sonarqube_data = {}
			sonarqube_logs = {}
			sonarqube_temp = {}
		}
	}
}

