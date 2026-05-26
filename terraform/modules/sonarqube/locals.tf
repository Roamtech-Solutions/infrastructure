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
  cloudsql_proxy_service_script = <<-EOT
		[Unit]
		Description=Cloud SQL Auth Proxy
		After=network.target

		[Service]
		Type=simple
		ExecStart=/usr/local/bin/cloud-sql-proxy \
			--auto-iam-authn \
			--private-ip \
			${local.database_connection}

		Restart=always
		RestartSec=5
		User=root

		[Install]
		WantedBy=multi-user.target
	EOT

	docker_compose = <<-EOT
    services:
      sonarqube:
        image: sonarqube:enterprise
        network_mode: "host"
        read_only: true
        # environment:
          # SONAR_JDBC_URL: jdbc:postgresql://db:5432/sonar
          # SONAR_JDBC_USERNAME: sonar
          # SONAR_JDBC_PASSWORD: sonar
        volumes:
          - sonarqube_data:/opt/sonarqube/data
          - sonarqube_logs:/opt/sonarqube/logs
          - sonarqube_temp:/opt/sonarqube/temp
        tmpfs:
          - /tmp:size=256M,mode=1777  # Add this line
    volumes:
      sonarqube_data:
      sonarqube_logs:
      sonarqube_temp:
	EOT

	startup_script = <<-EOT
		# Make sure Docker is installed
		type docker || curl https://get.docker.com | bash
	EOT
}

