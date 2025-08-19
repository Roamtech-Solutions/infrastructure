# PHP Laravel

PHP Laravel services are supported by the infrastructure build and deployment
framework.


## PHP Version

Currently the only PHP version supported is `8.4`.
If possible, please update you application and dependencies to work with this.

The plan is to change this, so that the version will be automatically determined
by the framework.



## Required Service Configurations

When adding an application to the `requires` property, the corresponding
environment variables are made available to the service.

These are all configured to the Laravel frameworks default variables, this is to
minimise the amount of effort needed to get the service set up.


### MySQL (`mysql`)

You must also set these options for the `mysql` connection in the
`config/database.php` file:

```php
            'options' => extension_loaded('pdo_mysql') ? array_filter([
		PDO::MYSQL_ATTR_SSL_CA => env('MYSQL_ATTR_SSL_CA'),
            ]) + [PDO::MYSQL_ATTR_SSL_VERIFY_SERVER_CERT => false,] : [],
```

This makes it so that the database connection is using the provided SSL
certificate and host name checking is disabled, since the name in the Cloud SQL
CA certificate isn't the same as the IP address that will be used.

The following variables are set for you automatically:

| Name			| Value 			| Description							|
|-----------------------|-------------------------------|---------------------------------------------------------------|
| `DB_CONNECTION`	| `mysql`			| Tell Laravel to use the MySQL database configurations.	|
| `MYSQL_ATTR_SSL_CA`	| `/etc/ssl/certs/mysql-ca.pem`	| Configure the SSL certificate used for connections.		|
| `DB_HOST`		| Dynamically set		| IP address/hostname of the MySQL instance.			|
| `DB_PORT`		| Dynamically set		| Port the instance is listening on.				|
| `DB_USERNAME`		| Dynamically set		| Username for the service to use.				|
| `DB_PASSWORD`		| Dynamically set		| Password for the service to use.				|


### RabbitMQ (`rabbitmq`)

| Name			| Value				| Description 							|
|-----------------------|-------------------------------|---------------------------------------------------------------|
| `RABBITMQ_HOST`	| Dynamically set		| IP address/hostname of the MQ instance.			|
| `RABBITMQ_PORT`	| Dynamically set		| Port the instance is listening on.				|
| `RABBITMQ_USER`	| Dynamically set		| Username for the service to use.				|
| `RABBITMQ_PASS`	| Dynamically set		| Password for the service to use.				|


### Redis (`redis`)

| Name			| Value				| Description 							|
|-----------------------|-------------------------------|---------------------------------------------------------------|
| `REDIS_CLIENT`	| `phpredis`			| Configure Laravel to use the `phpredis` driver.		|
| `SESSION_DRIVER`	| `redis`			| Configure Laravel to use Redis as the session driver.		|
| `REDIS_HOST`		| Dynamically set		| IP address/hostname of the Redis instance.			|
| `REDIS_PORT`		| Dynamically set		| Port the instance is listening on.				|
| `REDIS_USERNAME`	| Dynamically set		| Username for the service to use.				|
| `REDIS_PASSWORD`	| Dynamically set		| Password for the service to use.				|

