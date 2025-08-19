# Java Spring Boot

Java Spring Boot services are supported by the infrastructure build
and deployment framework.

## Java Version
The Java version of the Spring Boot service is determined by the
`java.version` property in the `pom.xml` file:

```xml
	<properties>
		<java.version>21</java.version>
	</properties>
```

If this isn't found, the Java version will default to `17`.


## Required Service Environment Variables

When adding an application to the `requires` property, the corresponding
environment variables are made available to the service.

These environment variables can be referenced in the
`application.properties` file of the service.


### MySQL (`mysql`)

| Name			| Description 					|
|-----------------------|-----------------------------------------------|
| `MYSQL_HOST`		| IP address/hostname of the MySQL instance.	|
| `MYSQL_PORT`		| Port the instance is listening on.		|
| `MYSQL_USER`		| Username for the service to use.		|
| `MYSQL_PASS`		| Password for the service to use.		|


### RabbitMQ (`rabbitmq`)

| Name			| Description 					|
|-----------------------|-----------------------------------------------|
| `RABBITMQ_HOST`	| IP address/hostname of the MQ instance.	|
| `RABBITMQ_PORT`	| Port the instance is listening on.		|
| `RABBITMQ_USER`	| Username for the service to use.		|
| `RABBITMQ_PASS`	| Password for the service to use.		|


### Redis (`redis`)

| Name			| Description 					|
|-----------------------|-----------------------------------------------|
| `REDIS_HOST`	| IP address/hostname of the Redis instance.		|
| `REDIS_PORT`	| Port the instance is listening on.			|
| `REDIS_USER`	| Username for the service to use.			|
| `REDIS_PASS`	| Password for the service to use.			|

