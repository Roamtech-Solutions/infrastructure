source "googlecompute" "mariadb" {
  project_id          = var.project_id
  zone                = "${var.region}-b"
  source_image_family = "debian-12"
  image_family        = "debian-base"
  image_name          = "mariadb-{{timestamp}}"
  subnetwork = "projects/${var.project_id}/regions/${var.region}/subnetworks/default"
	tags = ["ssh-via-iap"]
  ssh_username            = "packer"
  # omit_external_ip = true
  use_internal_ip = true
  use_iap         = true
  iap_tunnel_launch_wait   = 600
  ssh_timeout              = "1m"
  disk_size       = 30
}

build {
  sources = ["source.googlecompute.mariadb"]

  provisioner "shell" {
    script = "resources/mariadb-01-repo-setup.sh"
		execute_command = "chmod +x {{ .Path }}; sudo -E {{ .Path }}"
  }

  provisioner "shell" {
    script = "resources/mariadb-02-setup.sh"
		execute_command = "chmod +x {{ .Path }}; sudo -E {{ .Path }}"
  }
}

