#! /bin/sh

. scripts/common.sh

SERVICE_GROUP=${1}

gcloud --project ${PROJECT_ID} sql instances list \
	| grep ${SERVICE_GROUP} | head -1 | cut -w -f1

EXPORTS_BUCKET=${PROJECT_ID}-cloudsql-${SERVICE_GROUP}-exports

# gcloud sql export sql INSTANCE_NAME gs://BUCKET_NAME/sqldumpfile.gz \
# --database=DATABASE_NAME \
# --offload

# TODO: Establish what the source cloudsql instance is
# TODO: Establish what the source cloudsql exports bucket is
# TODO: Establish what the destination cloudsql instance is
# TODO: Establish what the destination cloudsql exports bucket is

# TODO: Export database to source bucket
# TODO: Copy database to destination bucket
# TODO: Import from destination bucket to destination database

  
