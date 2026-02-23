use admin;

%{ for user in users ~}

db.createUser(
  {
    user: "${user.name}",
    pwd: "${user.password}",
    roles: [{ role: "root", db: "admin" }]
  }
)

%{ endfor ~}

