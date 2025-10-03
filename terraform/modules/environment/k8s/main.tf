module "external-secrets" {
  source     = "../../external-secrets"
  project_id = local.project_id
}

/* === RabbitMQ Operater === */
resource "helm_release" "rabbitmq_cluster_operator" {
  name       = "rabbitmq-cluster-operator"
  chart = "${path.module}/../../../../helm/charts/rabbitmq-cluster-operator"
  namespace  = "rabbitmq"

  create_namespace = true
  # 15 Minute timeout, can take longer on intial cluster setup.
  timeout = 900

  values = [file(
    "${path.module}/../../../../helm/values/rabbitmq-cluster-operator.yaml"
  )]
}

/* === Strimzi Kafka Operater === */
resource "helm_release" "kafka_cluster_operator" {
  name       = "strimzi-kafka-operator"
  chart      = "strimzi-kafka-operator"
  repository = "https://strimzi.io/charts/"
  namespace  = "kafka"

  create_namespace = true
  # 15 Minute timeout, can take longer on intial cluster setup.
  timeout = 900
}

