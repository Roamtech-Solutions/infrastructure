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

variable "secondary_region" {
  type    = string
  default = "europe-west3"
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
  default = "db-n1-standard-1"
}

variable "mysql_database_flags" {
  type    = list(map(string))
  default = []
}

variable "postgresql_tier" {
  type    = string
  default = "db-f1-micro"
}

variable "postgresql_database_flags" {
  type    = list(map(string))
  default = []
}

variable "data_analytics_database_connections" {
  type    = list(string)
  default = []
}

# === Dynamic Imports === #

variable "import_sg_release" {
  type    = bool
  default = false
}

variable "import_redis_release" {
  type    = bool
  default = false
}

variable "import_service_releases" {
  type    = bool
  default = false
}

variable "excluded_service_releases" {
  type    = string
  default = ""
}

