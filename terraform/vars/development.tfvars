name = "development"
organisation = "457648173822"
billing_account = "012060-EBF262-CF6077"
region = "africa-south1"
services = [
	"compute.googleapis.com",
	"container.googleapis.com",
	"certificatemanager.googleapis.com",
	"secretmanager.googleapis.com",
	"logging.googleapis.com",
	"containeranalysis.googleapis.com",
	"containerscanning.googleapis.com",
	"networkmanagement.googleapis.com",
	"servicenetworking.googleapis.com",
]

application_services = {
	"nginx-service" = {
		tag = "e521e425"
		ingress = true
	}
}

