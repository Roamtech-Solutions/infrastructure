locals {
  /* Secrets to setup */
	secrets = lookup(yamldecode(var.values), "secrets", [])
	values = yamldecode(var.values)

	/* Security Policy */
	security_policy = (
		lookup(local.values, "public", false)
	) ? "${var.service_group}-public" : (
		lookup(local.values, "allowed_networks", {}) != {}
	) ? "${var.service_group}-${var.name}" :  var.service_group
}

