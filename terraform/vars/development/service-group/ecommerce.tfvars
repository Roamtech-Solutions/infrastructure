service_group = "ecommerce"
region        = "europe-west1"
host          = "roamtech.whitemire-technologies.com"
sub_host      = "ecom"

allowed_networks = {
  roamtech-office          = "41.139.128.197/32"
  roamtech-office-ethernet = "197.232.33.60/32"
  adenzo                   = "197.254.97.46/32"
}

# TODO: This should just be a group, not individuals
developers = [
  "user:timothy.kimani@roamtech.com",
]

