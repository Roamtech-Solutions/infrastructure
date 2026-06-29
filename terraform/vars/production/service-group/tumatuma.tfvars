service_group = "tumatuma"
region        = "europe-west1"
host          = "tumatuma.com"

allowed_networks = {
  bob                      = "81.156.238.206/32"
  bob_2                    = "109.181.189.243/32"
  roamtech-office          = "41.139.128.197/32"
  roamtech-office-ethernet = "197.232.33.60/32"
}

# TODO: This should just be a group, not individuals
developers = [
  "user:joshua.moracha@roamtech.com",
  "user:meriem.abubeker@roamtech.com",
  "user:andy.ruland@jiabalicrest.com",
  "user:victor.misiko@roamtech.com",
]

