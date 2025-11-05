#! /bin/sh

BUCKET=gs://management-b6d6-values

env=${1}
sg=${2}

if [ -z "${env}" ] || [ -z "${sg}" ]; then
	echo "Environment and service group are required."
	exit 1
fi

if [ "${env}" = "development" ]; then
	new_env=staging
elif [ "${env}" = "staging" ]; then
	new_env=production
fi

if [ -z "${new_env}" ]; then
	echo "Couldn't determine an environment to promote to from '${env}'"
	exit 1
fi

gcloud storage cp -r ${BUCKET}/${env}/${sg} ${BUCKET}/${new_env}/

