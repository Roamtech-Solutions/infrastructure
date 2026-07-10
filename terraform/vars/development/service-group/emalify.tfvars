service_group = "emalify"
region        = "europe-west1"
host          = "emalify.com"

# TODO: This should just be a group, not individuals
developers = [
  "user:fidelis.wambui@roamtech.com",
  "user:martin.mwenda@roamtech.com",
]

allowed_networks = {
  roamtech-office          = "41.139.128.197/32"
  roamtech-office-ethernet = "197.232.33.60/32"
}

