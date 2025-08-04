variable "project_id" {
  type = string
}

variable "name" {
  type = string
}

variable "service_group" {
  type = string
}

variable "tag" {
  type = string
}

variable "gar" {
  type = string
}

variable "ingress" {
  type = object({
    host = string
    dns_managed_zone = object({
      project_id = string
      name       = string
    })
  })
  default = null
}

variable "values" {
  type    = string
  default = ""
}

