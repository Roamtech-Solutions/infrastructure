name = "staging"
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
		tag = "0de7e4ee"
		ingress = true
	}
}

