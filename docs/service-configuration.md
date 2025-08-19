# Service Configuration

<!-- TODO: Link to document that explains setting up a new service  -->
How to configure services that have been setup.


## Overview

Each service repository has environment configuration files in the `env` folder.
For example, a configuration file for the `development` environment, would be:
`env/development.yaml`.

This file allows for setting environment-specific configurations for the service,
such as environment variables, secrets, RabbitMQ, MySQL and Redis connections.

## Example Configuration

Here is an example configuration that could be used:
```yaml

# Service Type, this determines how the application will be built and deployed.
type: java-spring-boot

# Environment variables can be configured and made available to the service.
# Secret values should not be stored in plain text here.
env:
  # Make an environment variable called 'ENVIRONMENT' with the value
  # 'development'
  - name: ENVIRONMENT
    value: development

# Secrets can also be made available to the service in environment variables.
# The values are set in Google Secret Manager, more information on this below.
secrets:
  # Make an environment variable called 'APP_KEY' which has the secret
  # value in it.
  - APP_KEY

# Supporting applications can have access enabled by including them in the
# requires property:
requires:
  - mysql

```

## Environments

The only available environment at the moment is `development`.
This will change soon.


## Properties


### `type`

The service type is set with the `type` property:
```yaml
type: SERVICE_TYPE
```

Select an avaiable service type and read the documentation to make sure
your service has been configured correctly:
- [`java-spring-boot`](/docs/service-type/java-spring-boot.md)
- [`php-laravel`](/docs/service-type/php-laravel.md)
- [`php-slim`](/docs/service-type/php-slim.md)


### `env`

Environment variables are set with the `env` property:

```yaml
env:
  - name: APP_NAME
    value: my-app
```

> 🔴 **WARNING: DO NOT STORE SECRETS IN PLAIN TEXT HERE, EVEN IF IT ISN'T A**
> **PRODUCTION ENVIRONMENT!**


### `secrets`

Secret values can be safely stored and acessed in environment variables by
the service by using the `secrets` property:

```yaml
secrets:
  - APP_KEY
```

The above example will create a secret and store the value in the `APP_KEY`
environment variable, the value of the secret must be configured manually in
[Google Cloud Secret Manager][google-secret-manager].

Please ask for assistance from a member of the [Infrastructure Team][infra-team]
if you would like to configure a secret value.


### `requires`
Applications _required_ by the service can be included in the `requires`
property:

```yaml
requires:
  - mysql
```

The environment variables for connecting to the applications will be configured
based on the service type provided.
Please see more information of the respective service type [here][service-types].


The available services to require currently are:
- `mysql`
- `rabbitmq`
- `redis`

> If there is an application you service requires that isn't listed here,
> please contact a member of the [Infrastructure Team][infra-team] to get it
> set up for you.


<!-- Links -->
[google-secret-manager]: https://cloud.google.com/security/products/secret-manager
[infra-team]: /docs/infra-team.md
[service-types]: /docs/service-type

