#! /bin/sh
# ============================================================================ #
# NAME
#	./scripts/rabbitmq-port-forward.sh
#
# SYNOPSIS
#	./scripts/rabbitmq-port-forward.sh SERVICE_GROUP
#
# DESCRIPTION
#	Port forward the RabbitMQ instance for the given service group and also
#	show the default credentials so that you can login.
#
# ============================================================================ #

SERVICE_GROUP=${1}

if [ -z "${SERVICE_GROUP}" ]; then
	echo "Service group not provided"
	exit 1
fi

kubectl -n ${SERVICE_GROUP} get secrets/rabbitmq-default-user \
	--template={{.data.username}} | base64 -d
echo ""
kubectl -n ${SERVICE_GROUP} get secrets/rabbitmq-default-user \
	--template={{.data.password}} | base64 -d
echo ""
kubectl -n ${SERVICE_GROUP} port-forward service/rabbitmq 15672:15672

