# Setup
Getting setup on the infrastructure project.

## Overview
To help engineers get set up with this project, there is a [Development Container][devcontainer] configured.
This works well with [Visual Studio Code][vscode], however there is also a [Development Container CLI][devcontainer-cli] that can be used.

This project also requires authentication to the Google Cloud API and the GitHub API if you are applying updates to the _management_ environment.

## Development Container Setup
If you are using Visual Studio Code, follow the installation guide [here][devcontainer-install].
For the CLI, follow the instructions for getting setup on the [GitHub Repository][devcontainer-cli].

Once you have followed these instructions, open the project in the development container.
The initial container build might take a little while, but subsequent start-ups wont take as long or will be instant.

> Note: All further steps must be completed whilst you are in the
> devcontainer.

## Authentication

### Google Cloud

You will mainly need access to the Google Cloud API, this is where most Terraform resources have been configured.

Run this command to setup credentials for Terraform to use:
```
gcloud auth application-default login
```
Follow the instructions given by the command output.

### GitHub
The GitHub API is used on the _management_ module to configure variables on the repositories and to also setup the workflows.

You can setup an authentication token for GitHub to use by running this GitHub CLI command:
```
gh auth login
```
Follow the instructions given by the command output.

## Summary
You should now have a working environment setup and properly authenticated.

<!-- Links -->
[devcontainer]: https://containers.dev/
[vscode]: https://code.visualstudio.com/
[devcontainer-cli]: https://github.com/devcontainers/cli
[devcontainer-install]: https://code.visualstudio.com/docs/devcontainers/containers#_installation
