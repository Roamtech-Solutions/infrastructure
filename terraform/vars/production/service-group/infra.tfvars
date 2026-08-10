service_group = "infra"
region        = "europe-west1"
host          = "paykit.africa"
sub_host      = "infra"

# TODO: This should just be a group, not individuals
developers = [
  # "user:bob.crutchley@roamtech.com",
  "user:ian.gacheru@roamtech.com",
]

allowed_networks = {
  bob                      = "80.71.4.141/32"
  bob_2                    = "109.181.189.243/32"
  roamtech-office          = "41.139.128.197/32"
  roamtech-office-ethernet = "197.232.33.60/32"
  all                      = "0.0.0.0/0"
}


