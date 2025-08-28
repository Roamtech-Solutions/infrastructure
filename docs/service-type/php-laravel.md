# PHP Laravel

PHP Laravel services are supported by the infrastructure build and deployment
framework.


## PHP Version

The PHP version is determined by what is set in the `require` property in the
`composer.json` file.

This will default to PHP version `8.4`, if it can't be determined from there.


## Stdout Logging

PHP Laravel applications by default are going to log to files in the `storage`
folder and there is no channel option for `stdout`.
This isn't very helpful when deploying in Kubernetes with multiple instances
because it makes checking the logs very difficult, causing you to log on to
every instance to view each file.
Writing the logs to `stdout` will make the logs easily visible in the Google
Cloud console, since `stdout` logs are collected automatically.

To do this, add a `stdout` logging channel to `config/logging.php`:
```php
	'stdout' => [
            'driver' => 'monolog',
            'handler' => StreamHandler::class,
            'with' => [
                'stream' => 'php://stdout',
            ],
        ]
```

Setting up this logging channel is required because the `LOG_CHANNEL`
environment variables gets set to `stdout` in the Kubernetes deployment.


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

