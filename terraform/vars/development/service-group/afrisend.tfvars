service_group = "afrisend"
region        = "europe-west1"
host          = "afrisend.com"

# TODO: This should just be a group, not individuals
developers = [
  "user:vanessa.chilumo@roamtech.com",
  "user:jennifer.wairimu@roamtech.com",
  "user:timothy.kimani@roamtech.com",
  "user:collins.mwadime@roamtech.com",
  "user:muchami.ngotho@afrisend.com",
  # "user:bob.crutchley@roamtech.com",
]

allowed_networks = {
  bob   = "81.146.4.244/32"
  bob_2 = "109.181.189.243/32"

  # Internal access points
  roamtech-office          = "41.139.128.197/32"
  roamtech-office-ethernet = "197.232.33.60/32"
  afrisend-office          = "197.248.97.137/32"
  afrisend-office-2        = "197.248.72.109/32"

  # Partner for testing integrations - requested by John Nderitu (john.nderitu@roamtech.com)
  al-muzaini-exchange = "3.109.39.95/32"
}

