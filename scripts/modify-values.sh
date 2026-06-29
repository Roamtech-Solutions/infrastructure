#! /bin/sh
# =========================================================================== #
# NAME
#	scripts/modify-values.sh
#
# DESCRIPTION
#	Modify the values file for a given service and environment with the
#	program configured in the EDITOR environment variable, defaulting to 
#	vim.
#
# SYNOPSIS
#	./scripts/modify-values.sh SERVICE
#
# EXAMPLES
#	# Modify the values file for the 'app' service in the 'afrisend'
#	# service group, in the 'production' environment:
#	ENVIRONMENT=production ./scripts/modify-values.sh afrisend-app
#
# =========================================================================== #

. scripts/common.sh

SERVICE=${1}
if [ -z "${SERVICE}" ]; then
	echo "Service not set"
	exit 1
fi

if [ -z "${ENVIRONMENT}" ]; then
	echo "Environment not set"
	exit 1
fi

test -n "${EDITOR}" || EDITOR=vim

NAME=$(echo "${SERVICE}" | sed 's/^[^-]*//g;s/^.//g')
GROUP=$(echo "${SERVICE}" | cut -d '-' -f 1)
BUCKET=gs://${MANAGEMENT_PROJECT_ID}-values

gcloud storage cp \
	${BUCKET}/${ENVIRONMENT}/${GROUP}/${NAME}.yaml \
	/tmp/values.yaml

${EDITOR} /tmp/values.yaml \
&& gcloud storage cp \
	/tmp/values.yaml \
	${BUCKET}/${ENVIRONMENT}/${GROUP}/${NAME}.yaml 

