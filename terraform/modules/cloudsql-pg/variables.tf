variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "zone" {
  type = string
}

variable "name" {
  type = string
}

variable "tier_primary" {
  type    = string
  default = "db-n1-standard-1"
}

variable "network" {
  type = object({
    id   = string
    name = string
  })
}

variable "database_version" {
  type = string
}

variable "disk_size" {
  type    = string
  default = "10"
}

variable "deletion_protection" {
  type    = bool
  default = false
}

variable "users" {
  type    = list(string)
  default = []
}

variable "edition" {
  type    = string
  default = "ENTERPRISE"
}

variable "developers" {
  type    = list(string)
  default = []
}

variable "database_flags" {
  type    = list(map(string))
  default = []
}

