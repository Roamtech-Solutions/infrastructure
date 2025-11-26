variable "environment" {
  type        = string
  description = "Environment name"
}

variable "custom_environment_name" {
  type        = string
  description = "Custom environment name for using a different URL"
  default     = ""
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
  type    = list(string)
  default = []
}

variable "allowed_networks" {
  type = map(string)
}

variable "mysql_tier" {
  type    = string
  default = "db-f1-micro"
}

variable "postgresql_tier" {
  type    = string
  default = "db-f1-micro"
}

