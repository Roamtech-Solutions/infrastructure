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

```

## Properties


### `type`

The service type is set with the `type` property:
```yaml
type: SERVICE_TYPE
```

Currently, the available types are:
  - `java-spring-boot`
  - `php-laravel`
  - `php-slim`


## `env`

Environment variables are set with the `env` property:

```yaml
env:
  - name: APP_NAME
    value: my-app
```

> <b style="colour: red">NOTE: DO NOT STORE SECRETS IN PLAIN TEXT HERE, EVEN IF IT ISN'T A</b>.
> <b style="colour: red">PRODUCTION ENVIRONMENT!</b>


## `secrets`

Secret values can be safely stored and acessed in the `secrets` by the service
by using the `secrets` property:

```yaml
secrets:
  - APP_KEY
```

The above example will create a secret and store the value in the `APP_KEY`
environment variable, the value of the secret must be configured manually in
[Google Cloud Secret Manager][google-secret-manager].

Please ask for assistance from a member of the infrastructure team if you
would like to configure a secret value.

[google-secret-manager]: https://cloud.google.com/security/products/secret-manager
