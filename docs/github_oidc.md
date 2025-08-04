# GitHub OIDC
OIDC allows for a keyless authentication from GitHub Actions to Google
Cloud.

## Workload Identity Pool
There is a workload identity pool configured in Google Cloud to authenticate connections from GitHub based on claims made in the request token.
This is works based of a trust relationship with GitHub, we are able to trust what attributes are sent and we test to make sure the GitHub organisation is the one which our source code is stored in.
Otherwise anyone could authenticate from GitHub actions, if they knew our project ID number and workload identity information.

### Terraform Implementation
Everything on Google Cloud has been set up in Terraform, a principle set is configured as an output to the module which provisions the workload identity pool.
The principal set is what we can assign IAM permissions to, in order to allow GitHub actions to modify our infrastructure.

## GitHub Actions Implementation
This example will authenticate with Google Cloud and store the short-lived
credentials in a file.
Subsequent steps will now be authenticated and be able to issue `gcloud` CLI commands or use tools like Terraform to interact with Google Cloud.

```yaml
jobs:
  auth_example:
    name: "Auth Example"
    runs-on: ubuntu-latest
    env:
      MANAGEMENT_PROJECT_ID: management-b6d6
      GOOGLE_CLOUD_WIP: 'projects/155168468510/locations/global/workloadIdentityPools/github/providers/github-provider'
    steps:
      - name: Google Cloud Authentication
        id: auth
        uses: 'google-github-actions/auth@v2'
        with:
          project_id: ${{ env.MANAGEMENT_PROJECT_ID }}
          workload_identity_provider: ${{ env.GOOGLE_CLOUD_WIP }}
          create_credentials_file: true
```

