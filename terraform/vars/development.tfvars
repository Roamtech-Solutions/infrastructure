name = "development"
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
allowed_networks = {
	bob = "81.151.140.163/32"
}

application_services = {
	"nginx-service" = {
		tag = "5325398b"
		ingress = true
	}
}

