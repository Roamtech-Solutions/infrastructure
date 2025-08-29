# Go

Go services are supported by the infrastructure build and deployment framework.


## Go Version

The Go version of the service is determined by the
`go` property in the `go.mod` file:

```xml
go 1.23.0
```

If this isn't found, the Go version will default to `1.23.0`.


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

