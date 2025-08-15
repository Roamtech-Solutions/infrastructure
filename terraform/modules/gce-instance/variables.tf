variable "project_id" {
  description = "The ID of the project in which the resources will be created"
  type        = string
}

variable "name" {
  description = "Name of the instance"
  type        = string
}

variable "machine_type" {
  description = "Machine type to use for the instance"
  type        = string
  default     = "f1-micro"
}

variable "zone" {
  description = "Zone where the instance will be created"
  type        = string
}

variable "boot_disk_image" {
  description = "Image to use for the boot disk"
  type        = string
  default     = "debian-cloud/debian-11"
}

variable "boot_disk_size" {
  description = "Size of the boot disk in GB"
  type        = number
  default     = 10
}

variable "boot_disk_type" {
  description = "Type of the boot disk"
  type        = string
  default     = "pd-standard"
}

variable "network" {
  description = "The VPC network to attach this instance to"
  type        = string
}

variable "subnetwork" {
  description = "The subnetwork to attach this instance to"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the instance"
  type        = list(string)
  default     = []
}

variable "metadata" {
  description = "Metadata key/value pairs to make available to the instance"
  type        = map(string)
  default     = {}
}

variable "startup_script" {
  description = "Startup script to be executed on instance boot"
  type        = string
  default     = ""
}
