locals {
  project_id = data.terraform_remote_state.core.outputs.project_id
  application_services = [
    for k, v in data.google_storage_bucket_objects.application_services.bucket_objects :
    replace(replace(v.name, "${var.name}/", ""), ".yaml", "")
  ]
}

