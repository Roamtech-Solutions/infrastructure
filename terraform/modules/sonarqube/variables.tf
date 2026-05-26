variable "project_id" {
	type = string
}

variable "name" {
	type = string
	default = "sonarqube"
}

variable "developers" {
	type = list(string)
}

variable "region" {
  type = string
}

# --- Compute Instance --- #
variable "machine_type" {
	type = string
	default = "c3-highcpu-4"
}

variable "boot_disk_size" {
	type = number
	default = 30
}

variable "network_name" {
  type = string
}

variable "subnetwork_name" {
  type = string
}
