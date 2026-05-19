/* --- Service Group Helm Chart --- */
import {
	for_each = (var.import_sg_release) ? toset(["1"]) : toset([])
  to = helm_release.service_group
  id = "${var.service_group}/${var.service_group}"
}

/* === Redis === */
import {
		for_each = (var.import_redis_release) ? toset(["1"]) : toset([])
    to = module.redis[0].helm_release.redis
    id = "${var.service_group}/redis"
}

/* === Application Services === */
import {
  for_each = (var.import_service_releases) ? {
		for k, v in data.google_storage_bucket_object_content.application_service_values : k => v
		if !contains(split(",", var.excluded_service_releases), k)
	} : {}
  to       = module.application_service[each.key].helm_release.application_service
  id       = "${var.service_group}/${each.key}"
}

