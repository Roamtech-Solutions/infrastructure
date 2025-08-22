locals {
  /* List of repository names which start with a known prefix */
  repository_names = [
    for repo in data.github_repositories.default.names : repo
    if(
      length([for prefix in var.prefixes : 1 if startswith(repo, prefix)]) > 0
    )
  ]
  repositories = {
    for k, v in data.github_repository.default : k => v
    if contains(local.repository_names, v.name)
  }
}

