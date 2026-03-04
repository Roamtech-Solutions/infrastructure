service_group = "afrisend"
region        = "europe-west1"
host          = "afrisend.com"

# TODO: This should just be a group, not individuals
developers = [
  "user:vanessa.chilumo@roamtech.com",
  "user:jennifer.wairimu@roamtech.com",
  "user:timothy.kimani@roamtech.com",
  "user:collins.mwadime@roamtech.com",

]

allowed_networks = {
  # Internal access points
  roamtech-office          = "41.139.128.197/32"
  roamtech-office-ethernet = "197.232.33.60/32"
  afrisend-office          = "197.248.97.137/32"
  afrisend-office-2        = "197.248.72.109/32"

  # Partner for testing integrations - requested by John Nderitu (john.nderitu@roamtech.com)
  al-muzaini-exchange = "3.109.39.95/32"
}

