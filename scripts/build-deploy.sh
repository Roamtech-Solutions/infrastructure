SERVICE=${1}
SERVICE_GROUP=$(echo "${SERVICE}" | cut -f 1 -d '-')

time ( ./scripts/docker-build-service.sh ${SERVICE} && make apply ENV=production MOD=service-group SG=${SERVICE_GROUP} )

