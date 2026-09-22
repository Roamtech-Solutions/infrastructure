host          = "paykit.africa"
service_group = "paykit"
region        = "europe-west1"


# TODO: This should just be a group, not individuals
developers = [
  "user:kevin.kariuki@roamtech.com",
  # "user:hosea@geartrain.co",
  "user:francis.kiarie@afrisend.com",
  "user:florence.muturi@roamtech.com",
  "user:victor.kinoti@roamtech.com",
]

allowed_networks = {
  afrisend-office          = "34.22.227.147/32"
  roamtech-office          = "41.139.128.197/32"
  roamtech-office-ethernet = "197.232.33.60/32"
}
