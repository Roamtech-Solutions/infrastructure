locals {
	create_users_script = templatefile(
		"${path.module}/resources/user-create.sql.tpl",
		{
			users = [for user in var.users : {
				name = user
				password = random_password.users[user].result
			}]
		}
	)
}

