# Roamtech Infrastructure


## Quick Start

- Login to Google Cloud:
  ```shell
  gcloud auth application-default login
  ```
- Deploy infrastructure changes with makefile wrapper for Terraform,
  in this case, for the development environment:
  ```shell
  make apply ENV=development LAYER=infra
  make apply ENV=development LAYER=k8s
  ```

