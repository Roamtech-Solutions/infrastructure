output "management" {
	value =  (var.name == "management") ? module.management[0] : {}
}

