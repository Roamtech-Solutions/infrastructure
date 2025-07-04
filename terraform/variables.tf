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

variable "regions" {
	type = list(string)
	description = "Regions to deploy to"
	default = ["africa-south1"]
}

variable "services" {
	type = list(string)
	description = "List of services to be enabled on the project"
}

variable "management_project_id" {
	type = string
	default = "management-1ddd"
}

variable "allowed_networks" {
	type = map(string)
	default = {
		bob = "81.151.140.163/32"
	}
}

