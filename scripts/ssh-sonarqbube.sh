#! /bin/sh
. scripts/common.sh

gcloud compute ssh \
	--zone "europe-west1-b" "sonarqube" \
	--project "${PROJECT_ID_PRODUCTION}" \
	--tunnel-through-iap
