service_group = "data"
region        = "europe-west1"
host          = "paykit.africa"
sub_host      = "data"

allowed_networks = {
  roamtech-office          = "41.139.128.197/32"
  roamtech-office-ethernet = "197.232.33.60/32"
}

developers = [
  "user:henry.kuria@roamtech.com",
  "user:teresia.elijah@roamtech.com",
  "user:mark.omari@roamtech.com",
]

postgresql_database_flags = [
  { name = "max_connections", value = "128" }
]

