variable "project_id" {
  type = string
}

variable "name" {
  type = string
}

variable "region" {
	type = string
}

variable "gar_project_id" {
  type = string
	description = "Project to create the GARs in"
}

variable "gar_region" {
	type = string
	description = "Region where the GARs are hosted"
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

