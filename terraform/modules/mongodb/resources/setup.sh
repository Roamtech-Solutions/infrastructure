#! /bin/sh
apt update
apt install -y gnupg curl

# === MongoDB Setup === #
# Config
mkdir -p /etc/mongod.conf.d
gsutil cp gs://${bucket}/mongod.conf /etc/mongod.conf

# Install
curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | \
   sudo gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg \
   --dearmor
echo "deb [ signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/debian bookworm/mongodb-org/8.0 main" | sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list
apt update
apt install -y mongodb-org
systemctl daemon-reload
systemctl enable --now mongod

# Give MongoDB a few seconds to start
sleep 5

# Setup Users
gsutil cp gs://${bucket}/user-create.js .
mongosh --file user-create.js

# Enable authorization
sed -i "s/authorization: disabled/authorization: enabled/g" /etc/mongod.conf
systemctl restart mongod
systemctl enable mongod

