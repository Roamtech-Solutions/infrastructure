locals {
	repositories = [
		for repo in data.github_repositories.default.names : repo
		if repo != "infrastructure"
	]
}

