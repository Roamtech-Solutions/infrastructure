variable "environment" {
  type        = string
  description = "Environment name"
}

variable "service_group" {
  type        = string
  description = "Service Group"
}

variable "management_project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "host" {
  type = string
}

variable "sub_host" {
  type    = string
  default = ""
}

variable "developers" {
	type = list(string)
	default = []
}

