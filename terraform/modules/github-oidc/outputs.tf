output "principal_set" {
  value = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.default.name}/*"
}

