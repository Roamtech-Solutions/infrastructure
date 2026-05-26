# Download and install SonarQube to /opt

SONAR_VERSION="2026.3.0.123014"
SONAR_ZIP="sonarqube-enterprise-${SONAR_VERSION}.zip"
SONAR_ZIP_URL="https://binaries.sonarsource.com/CommercialDistribution/sonarqube-enterprise/${SONAR_ZIP}"
curl -Lo "${SONAR_ZIP_URL}"
mkdir -p /opt/sonarqube
unzip ${SONAR_ZIP} -d /opt/sonarqube

# Enable the settings Elasticsearch wants

# Start SonarQube

