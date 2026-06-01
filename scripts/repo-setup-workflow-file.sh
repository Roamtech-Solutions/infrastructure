#! /bin/sh
# =========================================================================== #
#
# DESCRIPTION:
#	Install a given workflow file in all provided repos to the default
#	branch.
#	GitHub organisation and host is assumed based on ./scripts/common.sh
#
# SYNOPSIS:
#	./scripts/repo-setup-workflow-file.sh FILE REPOSITORIES
#	
# EXAMPLES:
#	Install a local /tmp/sandbox.yaml file to
#	.github/workflows/sandbox.yaml in the paykit-api repository:
#
#	./scripts/repo-setup-workflow-file.sh /tmp/sandbox.yaml paykit-api
#
#
#	Install a workflow file for all repositories in the paykit service
#	group:
#
#	./scripts/repo-setup-workflow-file.sh /tmp/sandbox.yaml \
#		$(./scripts/github-repo-search.sh paykit)
#	
# =========================================================================== #
. scripts/common.sh

setup_workflow() {
	# Make sure repository has been provided so we don't delete /tmp
	if [ -z "${1}" ]; then
		echo "No repository provided"
		exit 1
	fi
	rm -rf /tmp/${1}
	git clone $(github_ssh_url ${1}) /tmp/${1}
	cd /tmp/${1}
	mkdir -p .github/workflows
	cp ${WORKFLOW_FILE} .github/workflows/
	git add .
	# Check in the new file, if it wasn't already there.
	if git commit -m "add $(basename ${WORKFLOW_FILE})"; then
		git push -u origin $(git branch --show-current)
	else
		echo "Assuming file already exists..."
	fi
	cd -
	rm -rf /tmp/${1}
}

WORKFLOW_FILE=${1}

shift 1

for repo in "${@}"; do
	setup_workflow ${repo}
done

