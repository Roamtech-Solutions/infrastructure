name = "management"
services = [
  "compute.googleapis.com",
  "container.googleapis.com",
  "certificatemanager.googleapis.com",
  "secretmanager.googleapis.com",
  "logging.googleapis.com",
  "containeranalysis.googleapis.com",
  "containerscanning.googleapis.com",
  "networkmanagement.googleapis.com",
  "servicenetworking.googleapis.com",
  "cloudresourcemanager.googleapis.com",
  "sqladmin.googleapis.com",
  "cloudbuild.googleapis.com",
]

github_organisation = "Roamtech-Solutions"
github_app = {
	id = "1819150"
	installation_id = "82073011"
}

allowed_networks = {
  bob = "81.151.140.163/32",
}

service_groups = [
  "test",
  "adenzo",
  "imt",
  "emalify",
  "payments",
]

