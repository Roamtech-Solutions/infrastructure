locals {
  /* Secrets to setup */
  secrets = lookup(yamldecode(var.values), "secrets", [])
}

