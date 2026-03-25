#! /bin/sh
# ============================================================================ #
#
# NAME
# 	./scripts/terraform-target-apply-repos.sh
# 
# SYNOPSIS
# 	./scripts/terraform-target-apply-repos.sh REPOS
# 
# DESCRIPTION
# 	Apply the secrets Terraform in the service-group module for a given service
# 	(terraform/modules/environment/service-group)
#	This is handy for making sure the secrets are provisioned before
#	deploying, giving you a chance to populate them and avoiding deployment
#	failures.
# 
# EXAMPLES
# 
#	# Make sure the that the paykit-ipsl-rest-wrapper service has its
#	# secrets created:
#
#	./scripts/terraform-target-apply-secrets.sh paykit-ipsl-rest-wrapper
#
# ============================================================================
# #
set -e

# Environment
if [ "${ENV}" = "" ]; then
	ENV=development
fi
export ENV

# Service details
SERVICE=${1}
if [ "${SERVICE}" = "" ]; then
	echo "SERVICE not provided"
	exit 1
fi

export NAME=$(echo "${SERVICE}" | sed 's/^[^-]*//g;s/^.//g') export SG=$(echo "${SERVICE}" | cut -d '-' -f 1)

# Terraform arguments for targeting
export TF_ARGS="${TF_ARGS} -target=\"module.application_service[\\\"${NAME}\\\"].google_secret_manager_secret.default\""

echo "${TF_ARGS}"

make apply MOD=service-group

