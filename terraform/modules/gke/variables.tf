variable "project_id" {
  type = string
}

variable "name" {
  type = string
}

variable "region" {
	type = string
}

variable "docker_gar" {
	type = object({
		name = string
		location = string
		project_id = string
	})
}


variable "cluster_developers" {
	type = list(string)
	description = "Members who can manage resources in the cluster"
	default = []
}

variable "allowed_networks" {
	type = map(string)
	description = "Networks that can connect to configure the cluster"
	default = {}
}

