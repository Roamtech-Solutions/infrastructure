#! /bin/sh
# Common values and functions

set -e
set -x

export ENV
export ENVIRONMENT=${ENV}

export MANAGEMENT_PROJECT_ID="management-b6d6"
export PROJECT_ID_MANAGEMENT="management-b6d6"
export PROJECT_ID_PRODUCTION="production-e6a8"
export PROJECT_ID_STAGING="staging-3924"
export PROJECT_ID_DEVELOPMENT="development-30af"

# Project ID can be figured out based on the name
export PROJECT_ID=$( \
	eval echo \
		"\${PROJECT_ID_$(echo ${ENVIRONMENT} | tr 'a-z' 'A-Z')}" \
)

export REGION="europe-west1"

# GitHub
export GITHUB_HOST="github.com"
export GITHUB_ORG="Roamtech-Solutions"

github_ssh_url() {
	if [ -z "${1}" ]; then
		echo ""
	fi
	echo git@${GITHUB_HOST}:${GITHUB_ORG}/${1}.git 
}

