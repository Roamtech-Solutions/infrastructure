#! /bin/sh
# ============================================================================ #
# NAME
#	./scripts/cloudsql-port-forward.sh
#
# SYNOPSIS
#	./scripts/cloudsql-port-forward.sh CONNECTION_NAME [PORT]
#
# DESCRIPTION
#	Create a tunneled connection to the CloudSQL instance making it
#	available at localhost:3306 on your machine.
#	If ports are clashing on the jump box, you can provide one. It will
#	still be available locally on your machine at localhost:3306.
#
# EXAMPLES
#
#	# Connection to emalify production database:
#	./scripts/cloudsql-port-forward.sh \
#		production-e6a8:europe-west1:emalify-1b805db5
#
#	# Connection to emalify production database with port 6000 on the jump
#	# box:
#	./scripts/cloudsql-port-forward.sh \
#		production-e6a8:europe-west1:emalify-1b805db5 6000
#
# ============================================================================ #

set -x
set -e

CONNECTION_NAME="${1}"
if [ -z "${CONNECTION_NAME}" ]; then
	echo "Connection name not set"
	exit 1
fi

PROJECT=$(echo "${CONNECTION_NAME}" | cut -f 1 -d ':')
if [ -z "${PROJECT}" ]; then
	echo "Could not set project based on connection name"
	exit 1
fi

PORT="${2}"
if [ -z "${PORT}" ]; then
	PORT="3306"
fi

gcloud compute ssh \
	--project ${PROJECT} gke-europe-west1-jump-box \
	--command="cloud-sql-proxy --private-ip ${CONNECTION_NAME} --port ${PORT}" \
	-- \
	-L 3306:localhost:${PORT}
