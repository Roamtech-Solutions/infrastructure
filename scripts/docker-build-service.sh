#! /bin/sh
# ============================================================================ #
# NAME
#	./scripts/docker-build-service.sh
#
# SYNOPSIS
#	./scripts/docker-build-service.sh SERVICE_NAME
#
# DESCRIPTION
#	Build the given service with the appropriate parameters.
#
# ============================================================================ #

. scripts/common.sh

# Establish service name
if [ -d "${1}" ]; then
	# Folder name provided
	export SERVICE_NAME=$(basename "${1}")
	export SERVICE_DIR="$(cd ${1} && pwd)"
else
	export SERVICE_NAME=${1}
	if [ -z "${SERVICE_NAME}" ]; then
		echo "Service name not provided."
		exit 1
	fi
fi

if [ -z "${ENVIRONMENT}" ]; then
	export ENVIRONMENT=development
fi

# Prepare service build directory
export INFRA_DIR=${PWD}

# Use a temporary folder if one isn't provided
if [ -z "${SERVICE_DIR}" ]; then
	export SERVICE_DIR=${PWD}/tmp/${SERVICE_NAME}
fi


# Clone the service if it isn't there
if [ ! -d "${SERVICE_DIR}" ]; then
	git clone $(github_ssh_url ${SERVICE_NAME}) ${SERVICE_DIR}
fi

cp -r docker ${SERVICE_DIR}

# Service type & configurations
export NAME=$(echo "${SERVICE_NAME}" | sed 's/^[^-]*//g;s/^.//g')
export GROUP=$(echo "${SERVICE_NAME}" | cut -d '-' -f 1)
export VERSION=$(git rev-parse HEAD)
export TYPE=$(yq '.type' ${SERVICE_DIR}/env/${ENVIRONMENT}.yaml)

go_config() {
	if [ -z "${SERVICE_DIR}" ]; then
		echo "${0}:${LINENO}: Project directory has not been set"
		exit 1
	fi

	# --- Go Version --- #
	if [ -f ${SERVICE_DIR}/go.mod ]; then
		# Extract version from the .mod file
		export GO_VERSION=$(grep -E '^go ' ${SERVICE_DIR}/go.mod | cut -d' ' -f 2)
	else
		export GO_VERSION=1.23.0
	fi

        # --- Go Run Image --- #
        # Some dependencies mean that we can't build static binaries,
	# such as v8go.
        # In this case CGO_ENABLED is set to 1 and another image is used.
        if [ -f ${SERVICE_DIR}/go.mod && grep -e 'v8go' ${SERVICE_DIR}/go.mod ]; then 
		export GO_RUN_IMAGE=golang:${GO_VERSION}
		export CGO_ENABLED=1
	else
            export GO_RUN_IMAGE=alpine:latest
            export CGO_ENABLED=0
	fi
}


# --- PHP Version --- #
if [ -f ${SERVICE_DIR}/composer.json ]; then
	export PHP_VERSION=$(jq -r '.require.php' ${SERVICE_DIR}/composer.json | grep -o '[0-9.]\+')
	else
	export PHP_VERSION=8.4
fi

# --- Java --- #
if [ -f ${SERVICE_DIR}/pom.xml ]; then
	export JAVA_VERSION=$(grep -oP '(?<=<java.version>).*?(?=</java.version>)' ${SERVICE_DIR}/pom.xml)
else
	export JAVA_VERSION=17
fi

# --- Build & push the images --- #
docker compose -f docker/${TYPE}.yaml build
docker compose -f docker/${TYPE}.yaml push --ignore-push-failures

# --- Values File --- #
echo "tag: ${VERSION}" > tmp/values.yaml
echo "environment: ${ENVIRONMENT}" >> tmp/values.yaml
envsubst < ${SERVICE_DIR}/env/${ENVIRONMENT}.yaml >> tmp/values.yaml
gcloud storage cp tmp/values.yaml \
	gs://${MANAGEMENT_PROJECT_ID}-values/${ENVIRONMENT}/${GROUP}/${NAME}.yaml

