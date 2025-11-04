locals {
  /* Secrets to setup */
	secrets = lookup(yamldecode(var.values), "secrets", [])
  enabled_secrets = [
		for i in local.secrets : i if data.google_secret_manager_secret_version.all[i].enabled
	]
	values = yamldecode(var.values)
}

