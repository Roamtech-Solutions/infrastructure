# GitLab OIDC

## Getting the Audience Value
1. Make sure you are logged in:
   ```shell
   gcloud auth application-default login
  ```
2. Configure the backend to use the management state:
   ```shell
   make init ENV=management
   ```
3. Display the workload identity pool provider resource:
   ```shell
   terraform -chdir=terraform state show module.management[0].module.gitlab_oidc.google_iam_workload_identity_pool_provider.gitlab_provider_jwt
   ```
   There will be a `name` property in this resource, the value is required for the audience attribute in an OIDC exchange.

