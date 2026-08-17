service_group = "emalify"
region        = "europe-west1"
host          = "emalify.com"

# TODO: This should just be a group, not individuals
developers = [
  # "user:bob.crutchley@roamtech.com",
  # "user:fidelis.wambui@roamtech.com",
  "user:ian.gacheru@roamtech.com",
  "user:joshua.moracha@roamtech.com",
  "user:einstein.njoroge@afrisend.com",
  "user:teresia.elijah@roamtech.com",
  "user:racheal.wambui@roamtech.com",
]

allowed_networks = {
  bob                      = "80.71.4.141/32"
  roamtech-office          = "41.139.128.197/32"
  roamtech-office-ethernet = "197.232.33.60/32"
}

mysql_tier = "db-custom-4-16384"

mysql_database_flags = [
  { name = "max_connections", value = "500" }
]

