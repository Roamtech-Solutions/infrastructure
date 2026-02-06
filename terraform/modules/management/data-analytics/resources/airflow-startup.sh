#!/bin/sh
set -e

# Install docker
type docker > /dev/null 2>&1 || curl -L https://get.docker.com/ | bash
systemctl enable --now docker 

# Make sure airflow user is setup
id airflow > /dev/null 2>&1 || sudo useradd -m -s /bin/bash airflow
id -nG airflow | grep -qw docker || sudo usermod -aG docker airflow

# Configure environment variables
su - airflow -c "echo -e \"AIRFLOW_UID=$(id -u airflow)\" > .env"

# Initialise and start Airflow
su - airflow -c "curl -LfO 'https://airflow.apache.org/docs/apache-airflow/3.1.7/docker-compose.yaml'"
su - airflow -c "docker compose up airflow-init "
su - airflow -c "docker compose up -d"

