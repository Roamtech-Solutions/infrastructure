#! /bin/sh
set -e
set -x

PROJECT_ID=$(curl -sH 'Metadata-Flavor: Google' metadata/computeMetadata/v1/project/project-id)
ZONE=$(curl -sH 'Metadata-Flavor: Google' metadata/computeMetadata/v1/instance/zone)
REGION=$(curl -sH 'Metadata-Flavor: Google' metadata/computeMetadata/v1/instance/region)
NAME=$(curl -sH 'Metadata-Flavor: Google' metadata/computeMetadata/v1/instance/name)
ASSETS_BUCKET=${PROJECT_ID}-vpn-assets

error() {
    echo "${@}"
    exit 1
}

# ============================================================================ #
# Install pritunl & mongodb
# ============================================================================ #
curl -sL https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh | bash -
apt update
apt --assume-yes install gnupg2 apt-transport-https google-cloud-ops-agent software-properties-common
gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 7568D9BB55FF9E5287D586017AE645C0CF8E292A
gpg --armor --export 7568D9BB55FF9E5287D586017AE645C0CF8E292A | tee /etc/apt/trusted.gpg.d/pritunl.asc
curl -fsSL https://pgp.mongodb.com/server-6.0.asc | gpg --dearmor -o /etc/apt/trusted.gpg.d/mongodb-server-6.0.gpg
add-apt-repository -y 'deb http://repo.pritunl.com/stable/apt jammy main'
add-apt-repository -y 'deb https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse'
apt update
apt install -y pritunl mongodb-org wireguard wireguard-tools

# ============================================================================ #
# Configure MongoDB
# ============================================================================ #
mkdir -p /etc/mongod.conf.d
gcloud secrets versions access latest --secret vpn-mongo-key > /etc/mongod.conf.d/mongo-key
chown mongodb:mongodb /etc/mongod.conf.d/mongo-key
chmod 0400 /etc/mongod.conf.d/mongo-key
gsutil cp gs://${ASSETS_BUCKET}/mongod.conf /etc/mongod.conf
systemctl start mongod
# Give MongoDB a few seconds to start
sleep 5
gcloud secrets versions access latest --secret vpn-mongo-setup-script | mongosh
sed -i "s/authorization: disabled/authorization: enabled/g" /etc/mongod.conf
systemctl restart mongod
systemctl enable mongod

# ============================================================================ #
# Configure Pritunl
# ============================================================================ #
gcloud secrets versions access latest --secret vpn-config > /etc/pritunl.conf
systemctl start pritunl
systemctl enable pritunl
# Let mongo and pritunl start
sleep 5
pritunl set app.reverse_proxy true
pritunl set app.redirect_server false
pritunl set app.server_ssl false
pritunl set app.server_port 80

# ============================================================================ #
# logrotate
# ============================================================================ #
apt install -y logrotate
gsutil cp gs://${ASSETS_BUCKET}/mongod-logrotate /etc/logrotate.d/mongod
systemctl restart logrotate

# ============================================================================ #
# Pritunl default credentials secret
# ============================================================================ #
creds_file=/root/vpn-default-credentials.txt
pritunl default-password | tail -n 2 | cut -d '"' -f 2 > ${creds_file}
gcloud secrets versions add vpn-web-console-credentials --data-file=${creds_file}
rm -f ${creds_file}
