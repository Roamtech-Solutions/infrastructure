# GitLab OIDC

The OIDC setup allows us to grant access to Google Cloud from the GitLab pipelines.
A workload identity pool and provider are setup in Google Cloud, the GitLab pipeline can then assume the permissions of service account we have setup in Google Cloud.

## Getting the Audience Value
The audience value is the name property for the workload identity resource.

1. Make sure you are logged in:
   ```shell
   gcloud auth application-default login
   ```
2. Show the outputs for the management environment
   ```shell
   make output ENV=management
   ```
   There will be a `workload_identity_pool_provider_name` property in this resource, the value is required for the audience attribute in an OIDC exchange.

