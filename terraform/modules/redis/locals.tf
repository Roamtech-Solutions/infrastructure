locals {
  users = {
    for user in var.users : user => random_password.users[user].result
  }
}

