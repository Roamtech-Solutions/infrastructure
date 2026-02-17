#!/bin/sh

# Install docker
type docker > /dev/null 2>&1 || curl -L https://get.docker.com | bash
systemctl enable --now docker 

# Install CloudSQL Proxy
curl -o /usr/local/bin/cloud-sql-proxy https://storage.googleapis.com/cloud-sql-connectors/cloud-sql-proxy/v2.21.0/cloud-sql-proxy.linux.amd64
chmod +x /usr/local/bin/cloud-sql-proxy
gsutil cp gs://${resources_bucket}/cloudsql-proxy.service \
	/etc/systemd/system/cloudsql-proxy.service
systemctl daemon-reload
systemctl enable --now cloudsql-proxy

# Make sure airflow user is setup
id airflow > /dev/null 2>&1 || sudo useradd -m -s /bin/bash airflow
id -nG airflow | grep -qw docker || sudo usermod -aG docker airflow

# Configure environment variables
su - airflow -c "echo -e \"AIRFLOW_UID=$$(id -u airflow)\" > .env"

# Initialise and start Airflow
su - airflow -c "curl -LfO 'https://airflow.apache.org/docs/apache-airflow/3.1.7/docker-compose.yaml'"
su - airflow -c "docker compose up airflow-init "
su - airflow -c "docker compose up -d"

