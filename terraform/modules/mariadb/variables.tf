variable "project_id" {
  type        = string
  description = "ID of the project to deploy the instance to"
}

variable "name" {
  type        = string
  description = "Name of the instance, used for prefixing"
}

variable "users" {
  type        = list(string)
  description = "Users that need to be setup on the database"
}

/* === Instance Configuration === */

variable "region" {
  type        = string
  description = "Region"
}

variable "machine_type" {
  type        = string
  description = "Type of machine to use."
  default     = "e2-medium"
}


/* --- Boot disk --- */

variable "boot_disk_size" {
  type        = number
  description = "Size of the database instance boot disk"
  default     = 30
}

variable "boot_disk_type" {
  type        = string
  description = "Type of the boot disk"
  default     = "pd-balanced"
}

/* --- Network --- */
variable "network_name" {
  type        = string
  description = "Name of the network to attach the instance to"
}

variable "subnetwork_name" {
  type        = string
  description = "Name of the subnetwork to attach the instance to"
}

