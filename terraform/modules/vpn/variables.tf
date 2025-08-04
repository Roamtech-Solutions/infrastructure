variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "host" {
  type        = string
  description = "Host to serve VPN from"
}

variable "dns_managed_zone" {
  type = object({
    project_id = string
    name       = string
  })
  description = "Managed zone to configure DNS records."
}

variable "allowed_networks" {
  type        = map(string)
  default     = {}
  description = "Networks which can access the VPN web console to manage it."
}

