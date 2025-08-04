resource "google_compute_security_policy" "default" {
  project = var.project_id
  name    = "vpn"
  type    = "CLOUD_ARMOR"

  rule {
    action   = "deny(403)"
    priority = "2147483647"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "Default deny rule"
  }

  dynamic "rule" {
    for_each = (length(keys(local.allowed_networks)) > 0) ? ["0"] : []
    content {
      action   = "allow"
      priority = "2"
      match {
        versioned_expr = "SRC_IPS_V1"
        config {
          src_ip_ranges = [for k, v in local.allowed_networks : v]
        }
      }
      description = "Allow custom CIDR ranges"
    }
  }

  rule {
    action   = "allow"
    priority = 10
    match {
      expr {
        expression = join(
          " || ",
          [
            for r in [
              "/key/*", "/k/*", "/ku/*"
            ] : "(request.path.matches('${r}'))"
          ]
        )
      }
    }
    description = "Allow VPN profile temporary links"
  }
}

