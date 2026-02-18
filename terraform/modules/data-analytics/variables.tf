variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "name" {
  type        = string
  description = "Environment name"
}

variable "environment" {
  type = string
}

variable "network_name" {
  type = string
}

variable "subnetwork_name" {
  type = string
}

variable "developers" {
  type        = list(string)
  description = "List of members to give IAM access to the project"
}

