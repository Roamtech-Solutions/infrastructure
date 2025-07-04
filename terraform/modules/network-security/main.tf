resource "google_compute_ssl_policy" "default" {
  project         = var.project_id
  name            = "default"
  min_tls_version = "TLS_1_2"
  profile         = "RESTRICTED"
}

#resource "google_compute_security_policy" "default" {
#  project = var.project_id
#  name    = "default"
#  type    = "CLOUD_ARMOR"
#
#	/* Deny all by default */
#  rule {
#    action   = "deny(403)"
#    priority = "2147483647"
#    match {
#      versioned_expr = "SRC_IPS_V1"
#      config {
#        src_ip_ranges = ["*"]
#      }
#    }
#    description = "Default deny rule"
#  }
#
#	/* Allow specified networks */
#  dynamic "rule" {
#    for_each = (length(keys(var.allowed_networks)) > 0) ? ["0"] : []
#    content {
#      action   = "allow"
#      priority = "2"
#      match {
#        versioned_expr = "SRC_IPS_V1"
#        config {
#          src_ip_ranges = [for k, v in var.allowed_networks : v]
#        }
#      }
#      description = "Allow custom CIDR ranges"
#    }
#  }
#}

