locals {
  allowed_networks = merge(
    var.allowed_networks,
    { vpn = "${google_compute_address.vpn.address}/32" }
  )
  secrets = {
    "config" = jsonencode(
      {
        debug                   = false
        bind_addr               = "0.0.0.0"
        port                    = 80
        log_path                = "/var/log/pritunl.log"
        temp_path               = "/tmp/pritunl_%r"
        local_address_interface = "auto"
        mongodb_uri             = "mongodb://vpn:${random_password.mongo["mongo-vpn-user-password"].result}@localhost:27017/vpn?authSource=admin"
        app = {
          reverse_proxy   = true
          redirect_server = false
          server_ssl      = false
          server_port     = 80
        }
      }
    )
    "mongo-setup-script"      = <<-EOF
      use admin
      db.createUser({
          user: "admin", pwd: "${random_password.mongo["mongo-admin-user-password"].result}",
          roles: [ { role: "userAdminAnyDatabase", db: "admin" },
                  { role: "clusterAdmin", db: "admin" } ]
      })
      db.createUser({
          user: "vpn", pwd: "${random_password.mongo["mongo-vpn-user-password"].result}",
          roles: [ { role: "dbOwner", db: "vpn" } ]
      })
    EOF
    "mongo-key"               = random_password.mongo_key.result
    "mongo-user-vpn-password" = random_password.mongo["mongo-vpn-user-password"].result
    "web-console-credentials" = "changeme"
  }
}
