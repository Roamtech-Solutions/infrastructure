#! /bin/sh
apt update
apt install -y curl apt-transport-https

# Install MariaDB
bash /tmp/mariadb-repo-setup.sh
apt install -y mariadb-server mariadb-client

# TODO: Setup Users

