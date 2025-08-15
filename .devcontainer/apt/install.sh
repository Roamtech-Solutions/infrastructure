apt update
apt install -y $(echo ${PACKAGES} | tr ',' ' ')

