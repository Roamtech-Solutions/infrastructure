name = "data-analytics"
services = [
  "compute.googleapis.com",
  "secretmanager.googleapis.com",
  "networkmanagement.googleapis.com",
  "logging.googleapis.com",
  "servicenetworking.googleapis.com",
  "sqladmin.googleapis.com",
  "bigquery.googleapis.com",
]

developers = [
  "user:henry.kuria@roamtech.com",
]


database_connections = [
  # Afrisend
  "production-e6a8:europe-west3:afrisend-96b3e145-replica-europe-west3",
  # Paykit
  "production-e6a8:europe-west3:paykit-c57f00b1-replica-europe-west3",
]

