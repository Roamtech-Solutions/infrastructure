host          = "paykit.africa"
service_group = "paykit"
region        = "europe-west1"


# TODO: This should just be a group, not individuals
developers = [
	"user:kevin.kariuki@roamtech.com",
	"user:hosea@geartrain.co",
	"user:francis.kiarie@roamtech.com",
]

allowed_networks = {
  roamtech-office = "41.139.128.197/32"
  roamtech-office-ethernet = "197.232.33.60/32"
}
