# /* --- Service Group Helm Chart --- */
# import {
#   to = helm_release.service_group
#   id = "${var.service_group}/${var.service_group}"
# }
# 
# /* === Redis === */
# import {
#     to = module.redis[0].helm_release.redis
#     id = "${var.service_group}/redis"
# }
# 
# /* === Application Services === */
# import {
#   for_each = data.google_storage_bucket_object_content.application_service_values
#   to       = module.application_service[each.key].helm_release.application_service
#   id       = "${var.service_group}/${each.key}"
# }

