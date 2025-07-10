locals {
	/* Ingress map if one has been configured */
	ingress = (var.ingress == null) ? {} : { "0" = var.ingress }
}

