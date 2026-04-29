# Redploying Kafka

Configurations for Kafka get stored in persistent volume claims, so redeploying
doesn't work unless you clear out those configs.

Here is how your can reset it with our setup:

```shell
SG="YOUR SERVICE GROUP NAME"
kubectl -n ${SG} get kafkanodepools
kubectl -n ${SG} delete kafkanodepools/broker
kubectl -n ${SG} delete kafkanodepools/controller
kubectl -n ${SG} delete pvc/data-0-paykit-broker-0 
kubectl -n ${SG} delete pvc/data-0-paykit-controller-1
helm -n ${SG} upgrade ${SG} helm/charts/service-group --reuse-values
```

If you are on the infrastructure repository, using the makefile is going to be
the easiest way to do this:
```shell
# make ENV=${ENVIRONMENT} SG=${SERVICE_GROUP} kafka-reset
make ENV=staging SG=paykit kafka-reset
```

