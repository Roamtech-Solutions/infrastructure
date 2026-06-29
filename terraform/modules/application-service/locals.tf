locals {
  values = yamldecode(var.values)

  /* Secrets to setup */
  wordpress_addtional_secrets = (local.values.type == "wordpress") ? [
    "AUTH_KEY",
    "SECURE_AUTH_KEY",
    "LOGGED_IN_KEY",
    "NONCE_KEY",
    "AUTH_SALT",
    "SECURE_AUTH_SALT",
    "LOGGED_IN_SALT",
    "NONCE_SALT",
  ] : []
  base_secrets = coalesce(lookup(yamldecode(var.values), "secrets", []), [])
  secrets = distinct(concat(
    local.base_secrets,
    local.wordpress_addtional_secrets
  ))

  /* Security Policy */
  security_policy = (
    lookup(local.values, "public", false)
    ) ? "${var.service_group}-public" : (
    lookup(local.values, "allowed_networks", {}) != {}
  ) ? "${var.service_group}-${var.name}" : var.service_group

  # all_buckets = merge(
  #   google_storage_bucket.default,
  #   { for k, v in google_storage_bucket.public : "public-${k}" => v }
  # )
  /* All buckets for IAM */
  all_buckets = merge(
    { for k in toset(lookup(local.values, "gcs_buckets", [])) :
      k => google_storage_bucket.default[k]
    },
    { for k in toset(lookup(local.values, "gcs_buckets_public", [])) :
      "public-${k}" => google_storage_bucket.public[k]
    }
  )

}

