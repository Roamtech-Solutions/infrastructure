locals {
	/* Ingress map if one has been configured */
	ingress = (var.ingress == null) ? {} : { "0" = var.ingress }
	
	# secrets = lookup(yamldecode(var.values), "secrets", {})
	# secrets_empty = lookup(yamldecode(local.secrets), "empty", {})

	# /* Collect secrets with a generated block */
	# secrets_generated = {
	# 	for k, v in local.secrets : "${var.name}-${k}" => v.generated
	# 		if lookup(k, "generated", null) != null
	# }

	mysql = lookup(yamldecode(var.values), "mysql", false)
}

