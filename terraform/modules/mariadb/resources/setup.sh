#! /bin/sh
apt update
apt install -y curl apt-transport-https

gsutil cp gs://${bucket}/mariadb-repo-setup.sh .
gsutil cp gs://${bucket}/user-create.sql .

# Install MariaDB
bash ./mariadb-repo-setup.sh
apt install -y mariadb-server mariadb-client

# Setup Users
mariadb -u root < user-create.sql

