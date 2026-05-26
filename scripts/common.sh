#! /bin/sh
# Common values and functions

set -e
set -x

export ENV
export ENVIRONMENT=${ENV}

export MANAGEMENT_PROJECT_ID="management-b6d6"
export REGION="europe-west1"

export GITHUB_HOST="github.com"
export GITHUB_ORG="Roamtech-Solutions"

github_ssh_url() {
	if [ -z "${1}" ]; then
		echo ""
	fi
	echo git@${GITHUB_HOST}:${GITHUB_ORG}/${1}.git 
}

