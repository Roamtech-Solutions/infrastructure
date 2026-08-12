host          = "paykit.africa"
service_group = "paykit"
region        = "europe-west1"


# TODO: This should just be a group, not individuals
developers = [
  "user:kevin.kariuki@roamtech.com",
  "user:francis.kiarie@roamtech.com",
  "user:einstein.njoroge@afrisend.com",
  # "user:hosea@geartrain.co",
  "user:victor.kinoti@roamtech.com"
]

allowed_networks = {
  roamtech-office          = "41.139.128.197/32"
  roamtech-office-ethernet = "197.232.33.60/32"
}

mysql_tier      = "db-n1-standard-1"
postgresql_tier = "db-custom-1-3840"

