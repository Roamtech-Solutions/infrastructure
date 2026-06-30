#! /bin/sh

. scripts/common.sh

command_export() {
	timestamp=$(date "+%Z-%Y-%m-%d_%H-%M-%S")
	gcloud --project ${PROJECT_ID} \
		sql export sql ${INSTANCE_NAME} \
		gs://${EXPORTS_BUCKET}/${timestamp}.gz \
		--database=${DATABASE_NAME}
}

command_import() {
	timestamp=${4}
	gcloud --project ${PROJECT_ID} \
		sql import sql ${INSTANCE_NAME} \
		gs://${EXPORTS_BUCKET}/${timestamp}.gz \
		--database=${DATABASE_NAME}
}

COMMAND=${1}
if test -z "${COMMAND}"; then
	echo "Command not provided"
	exit 1
fi

SERVICE_GROUP=${2}
if test -z "${SERVICE_GROUP}"; then
	echo "Service Group not provided"
	exit 1
fi

INSTANCE_NAME=$( \
	gcloud --project ${PROJECT_ID} sql instances list \
	| grep ${SERVICE_GROUP} | head -1 | cut -w -f1 \
)

DATABASE_NAME=${3}
if test -z "${DATABASE_NAME}"; then
	echo "Database Name not provided"
	exit 1
fi

EXPORTS_BUCKET=$( \
	gcloud --project ${PROJECT_ID} \
	storage buckets list --format "table(name)" \
	| grep tumatuma \
	| head -1 \
)

command_${COMMAND} $@

