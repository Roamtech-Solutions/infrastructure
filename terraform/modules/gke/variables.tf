variable "project_id" {
  type = string
}

variable "name" {
  type = string
}

variable "region" {
  type = string
}

variable "registry_project_ids" {
  type = list(string)
}

variable "cluster_developers" {
  type        = list(string)
  description = "Members who can manage resources in the cluster"
  default     = []
}

variable "allowed_networks" {
  type        = map(string)
  description = "Networks that can connect to configure the cluster"
  default     = {}
}

