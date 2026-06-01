locals {
  default_roles = [
    "roles/monitoring.metricWriter",
    "roles/storage.objectViewer",
    "roles/storage.objectCreator",
    "roles/stackdriver.resourceMetadata.writer",
    "roles/cloudsql.client",
    "roles/cloudsql.instanceUser",
  ]

	docker_compose = {
		services = {
		  sonarqube = {
		    image = "sonarqube:enterprise"
		    network_mode = "host"
		    read_only = true
		    environment = {
		      SONAR_JDBC_URL = "jdbc:mysql://localhost:3306/default?useConfigs=maxPerformance&useUnicode=true&characterEncoding=utf8&rewriteBatchedStatements=true&allowPublicKeyRetrieval=true&useSSL=false"
		      SONAR_JDBC_USERNAME = google_service_account.default.email
				}
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
        command = "--auto-iam-authn --address 0.0.0.0 --port 3306 --private-ip ${module.cloudsql.connection_name}"
			}
		}
		volumes = {
			sonarqube_data = {}
			sonarqube_logs = {}
			sonarqube_temp = {}
		}
	}
}

