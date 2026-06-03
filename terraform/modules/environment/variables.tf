# Variables for all environment modules are configured here.
# This saves on repeated configurations and stops the warnings # from Terraform when providing variables that aren't needed.

variable "name" {
  type        = string
  description = "Environment name"
}

variable "service_group" {
  type        = string
  description = "Service Group"
}

variable "organisation" {
  type        = string
  default     = null
  description = "ID for the organisation to create the project in"
}

variable "billing_account" {
  type        = string
  description = "ID of the billing account to use for the environment"
}

variable "region" {
  type    = string
  default = "africa-south1"
}

variable "hosts" {
  type = list(string)
}

variable "services" {
  type        = list(string)
  description = "List of services to be enabled on the project"
}

variable "management_project_id" {
  type = string
}

variable "allowed_networks" {
  type = map(string)
}

variable "ci_runner_ip" {
  type    = string
  default = ""
}

variable "log_retention_days" {
  type    = number
  default = 30
}

variable "developers" {
  type    = list(string)
  default = []
}

