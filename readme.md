# Roamtech Infrastructure
Repository housing all of Roamtechs Google Cloud infrastructure.

## Setup
Please see the [setup guide](./docs/setup.md) for getting setup on the project.

## Quick Start

- Deploy infrastructure changes with makefile wrapper for Terraform,
  in this case, for the development environment:
  ```shell
  # Plan a service group, in this case, afrisend
  make plan ENV=development MOD=service-group SG=afrisend
  ```

> Note: Make will can pick up settings from environment variables.
>	For example, this will still deploy to the development environment,
>	saving you from providing the value every time:
>	```
>	export ENV=development
>	make plan MOD=service-group SG=afrisend
>	```

