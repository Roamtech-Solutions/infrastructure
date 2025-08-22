variable "project_id" {
  type        = string
  description = "Google Cloud Project ID"
}

variable "github_organisation" {
  type        = string
  description = "GitHub Organisation Name"
}

variable "prefixes" {
  type        = list(string)
  description = "Setup onlt the projects that start with these prefixes"
}

