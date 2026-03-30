# Go

Go services are supported by the infrastructure build and deployment framework.


## Go Version

The Go version of the service is determined by the
`go` property in the `go.mod` file:

```xml
go 1.23.0
```

If this isn't found, the Go version will default to `1.23.0`.

## Custom environment variables

Environment variables used in Go projects can be found quite reliably with
this command:
```shell
grep -rnoP 'os.Getenv\(.*\)' | sed -E 's/.*Getenv\("(.*)"\)*$/\1/g'
```

These then need to be configured in the configuration YAML files either the
`env` block or in `secrets`.
See more [here][service-configuration].

## Required Service Environment Variables

When adding an application to the `requires` property, the corresponding
environment variables are made available to the service.

These environment variables can be accessed with the `os.Getenv` function
in your source code, see more [here][go-env-vars].


### MySQL (`mysql`)

| Name			| Description 					|
|-----------------------|-----------------------------------------------|
| `MYSQL_HOST`		| IP address/hostname of the MySQL instance.	|
| `MYSQL_REPLICA_HOST`	| IP address/hostname of the replica instance.	|
| `MYSQL_PORT`		| Port the instance is listening on.		|
| `MYSQL_USER`		| Username for the service to use.		|
| `MYSQL_PASS`		| Password for the service to use.		|

### MongoDB (`mongodb`)

| Name			| Description 					|
|-----------------------|-----------------------------------------------|
| `MONGODB_HOST`		| IP address/hostname of the instance.	|
| `MONGODB_PORT`		| Port the instance is listening on.	|
| `MONGODB_USER`		| Username for the service to use.	|
| `MONGODB_PASS`		| Password for the service to use.	|


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


<!-- Links -->
[go-env-vars]: https://gobyexample.com/environment-variables
[service-configuration]: /docs/service-configuration.md

