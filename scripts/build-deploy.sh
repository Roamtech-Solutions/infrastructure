set -e
set -x
if [ -z "${ENV}" ]; then
	ENV=development
	ENVIRONMENT=development
fi

export ENV
export ENVIRONMENT=${ENV}

# Build and update the values
for service in ${*}; do
	./scripts/docker-build-service.sh ${service}
done

# Deploy, assume that they are all in the same SG
service_group=$(echo "${1}" | cut -f 1 -d '-')
make apply MOD=service-group SG=${service_group}

