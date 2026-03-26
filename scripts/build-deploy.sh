SERVICE=${1}
SERVICE_GROUP=$(echo "${SERVICE}" | cut -f 1 -d '-')

if [ -z "${ENV}" ]; then
	ENV=development
	ENVIRONMENT=development
fi

export ENV
export ENVIRONMENT=${ENV}

time ( ./scripts/docker-build-service.sh ${SERVICE} && make apply MOD=service-group SG=${SERVICE_GROUP} )

