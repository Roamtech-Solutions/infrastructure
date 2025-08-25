# Build Types

Build types directly correlate with service types, the service type determines
what Docker images are going to be built.


## Overview

Dockerfiles and files associated with those builds are configured in the
[docker](./docker) folder.

These Docker builds can then be referenced by the docker build matrix
configurations, which are located in the [.github/matrix/](.github/matrix/)
folder.

The _service type_ correlates directly with the names of the build matrix
configurations. For example, the `java-spring-boot` service type will use the
`./.github/matrix/docker-java-spring-boot.json` file.

So based on the _service type_ there are 1 or more different Docker builds
that are made, depending on what has been set in the corresponding Docker
build matix configuration.


## Build Matrix Configuration

The build matrix configuration files are simple JSON files that indicate what
the name of the build is and where the Dockerfile is to build it.
This can be used by GitHub actions to dynamically build different Docker images,
depending on what has been set.

Here is the `php-laravel` as an example:
https://github.com/Roamtech-Solutions/infrastructure/blob/4e1ed2682d5d668a867dba4c00181eec38d52049/.github/matrix/docker-java-spring-boot.json#L1-8

> Here we can see that a Docker image called `app` will be built from the
> `docker/java-spring-boot/Dockerfile` file.

You can  have multiple images, for example see PHP Laravel:
https://github.com/Roamtech-Solutions/infrastructure/blob/4e1ed2682d5d668a867dba4c00181eec38d52049/.github/matrix/docker-php-laravel.json#L1-16

> This builds 3 images, which the service requires:
> - `nginx` for ingress to the application
> - `fpm` for listing for CGI requests from the `nginx` container
> - `cli` for performing migrations and other tasks


## GitHub Actions Implementation

GitHub Actions allows for job variations with
[Matrix Strategies][gha-matrix-strats].



[gha-matrix-strats]: https://docs.github.com/en/actions/how-tos/write-workflows/choose-what-workflows-do/run-job-variations
