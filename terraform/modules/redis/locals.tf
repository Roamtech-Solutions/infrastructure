locals {
  users = {
    for user in var.users : user => random_password.default[user].result
  }
}

