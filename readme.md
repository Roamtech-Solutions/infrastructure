# Roamtech Infrastructure


## Quick Start

- Login to Google Cloud:
  ```shell
  gcloud auth application-default login
  ```
- Deploy infrastructure changes with makefile wrapper for Terraform,
  in this case, for the development environment:
  ```shell
  make apply ENV=development MODULE=infra
  make apply ENV=development MODULE=k8s
  ```

> Note: Make will can pick up settings from environment variables.
>	For example, this will still deploy to development, saving you
>	from providing the value every time:
>	```
>	export ENV=development
>	make apply  MODULE=k8s
>	```

