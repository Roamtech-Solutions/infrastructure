data "terraform_remote_state" "core" {
  backend  = "gcs"
  config = {
    bucket = "${var.management_project_id}-tfstate"
		prefix = "${var.name}/core"
  }
}

data "terraform_remote_state" "management" {
  backend  = "gcs"
  config = {
    bucket = "${var.management_project_id}-tfstate"
		prefix = "management"
  }
}

