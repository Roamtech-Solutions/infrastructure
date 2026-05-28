#! /bin/sh
# Install a workflow file in all repos to the default branch

. scripts/common.sh

setup_workflow() {
	git clone $(github_ssh_url ${1}) /tmp/${1}
	cd /tmp/${1}
	mkdir -p .github/workflows
	cp ${WORKFLOW_FILE} .github/workflows/
	git add .
	git commit -m "add $(basename ${WORKFLOW_FILE})"
	git push -u origin $(git branch --show-current)
	cd -
	rm -rf /tmp/${1}
}

WORKFLOW_FILE=${1}

shift 1

for repo in "${@}"; do
	setup_workflow ${repo}
done

