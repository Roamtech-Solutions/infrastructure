variable "region" {
	type = string
}

variable "gitlab_project_id" {
	type = string
}

variable "name" {
	type = string
	description = "Environment name"
}

variable "organisation" {
	type = string
	default = null
	description = "ID for the organisation to create the project in"
}

variable "billing_account" {
	type = string
	description = "ID of the billing account to use for the environment"
}

variable "services" {
	type = list(string)
	description = "List of services to be enabled on the project"
}

variable "allowed_networks" {
	type = map(string)
}

/* Unused variables */
variable "management_project_id" {
	type = string
	default = ""
}

