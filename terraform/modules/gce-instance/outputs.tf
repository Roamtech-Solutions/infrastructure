output "service_account_member" {
    description = "The member string for the service account attached to the instance."
    value = google_service_account.default.member
}
