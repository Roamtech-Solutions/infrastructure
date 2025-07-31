output "ca_cert" {
  value = module.cloudsql.instance_server_ca_cert.0.cert
}

output "private_ip_address" {
	value = module.cloudsql.private_ip_address
}

