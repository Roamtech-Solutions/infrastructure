variable "project_id" {
	type = string
}

variable "issuers" {
	type = map(string)
	default = {
		default = "https://gitlab.com"
	}
}

variable "gitlab_namespace_path" {
	type = string
}

