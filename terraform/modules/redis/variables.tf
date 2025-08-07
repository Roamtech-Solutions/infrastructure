variable "project_id" {
  type = string
}

variable "prefix" {
	type = string
}

variable "users" {
  type = list(string)
}

variable "port" {
  type    = number
  default = 6379
}

variable "config_file" {
  type    = string
  default = "/data/nodes.conf"
}

variable "enable_cluster" {
  type    = bool
  default = false
}

