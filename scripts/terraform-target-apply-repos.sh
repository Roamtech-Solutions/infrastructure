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
# 	Apply the Terraform in the management core module
#	(terraform/modules/management/core) for the specified repositories.
# 
# EXAMPLES
# 
#	# Make sure the that the paykit-ipsl-rest-wrapper repositotry is
#	# configured by Terraform:
#
#	./scripts/terraform-target-apply-repos.sh paykit-ipsl-rest-wrapper
#
# ============================================================================ #
set -e

if [ "${*}" = "" ]; then
	echo "No repos were provided."
	exit 1
fi

TF_ARGS=""

for repo in ${*}; do
	resource_key="Roamtech-Solutions/${repo}"
	TF_ARGS="${TF_ARGS} -target=\"module.github_actions.github_actions_secret.infra-pat[\\\"${resource_key}\\\"]\""
	TF_ARGS="${TF_ARGS} -target=\"module.github_actions.github_actions_variable.service_group[\\\"${resource_key}\\\"]\""
	TF_ARGS="${TF_ARGS} -target=\"module.github_actions.github_actions_variable.service_name[\\\"${resource_key}\\\"]\""
	TF_ARGS="${TF_ARGS} -target=\"module.github_actions.github_repository_file.workflow_development[\\\"${resource_key}\\\"]\""
	TF_ARGS="${TF_ARGS} -target=\"module.github_actions.github_repository_file.workflow_staging[\\\"${resource_key}\\\"]\""
done

export TF_ARGS

make apply ENV=management MOD=core

