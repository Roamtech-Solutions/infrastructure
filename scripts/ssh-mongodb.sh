#! /bin/sh
. scripts/common.sh

SERVICE_GROUP=${1}
if test -z "${SERVICE_GROUP}"; then
	echo "Service Group not provided"
	exit 1
fi

gcloud compute ssh \
	--zone "europe-west1-b" "${SERVICE_GROUP}-mongodb" \
	--project "${PROJECT_ID}" \
	--tunnel-through-iap
