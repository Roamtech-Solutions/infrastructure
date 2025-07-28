resource "google_storage_bucket" "assets" {
  project                     = var.project_id
  name                        = "${var.project_id}-vpn-assets"
  location                    = "EU"
  public_access_prevention    = "enforced"
  force_destroy               = true
  uniform_bucket_level_access = true
  versioning {
    enabled = true
  }
}

resource "google_storage_bucket_object" "assets" {
  for_each = toset([
    "mongod.conf",
    "mongod-logrotate",
    "vpn-startup.sh",
  ])
  name     = each.key
  source   = "${path.module}/resources/${each.key}"
  bucket   = google_storage_bucket.assets.name
  metadata = {}
}
