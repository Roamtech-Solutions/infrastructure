# Build Types

Build types directly correlate with service types, the service type determines
what Docker images are going to be built.


## Overview

Dockerfiles and files associated with those builds are configured in the
[`docker`](/docker) folder.

These Docker builds can then be referenced by the docker build matrix
configurations, which are located in the [`.github/matrix/`](/.github/matrix/)
folder.

The _service type_ correlates directly with the names of the build matrix
configurations. For example, the `java-spring-boot` service type will use the
[`.github/matrix/docker-java-spring-boot.json`](/.github/matrix/docker-java-spring-boot.json)
file.

So based on the _service type_ there are 1 or more different Docker builds
that are made, depending on what has been set in the corresponding Docker
build matix configuration.


## Build Matrix Configuration

The build matrix configuration files are simple JSON files that indicate what
the name of the build is and where the Dockerfile is to build it.
This can be used by GitHub actions to dynamically build different Docker images,
depending on what has been set.

Here is the `java-spring-boot` build matrix as an example:
https://github.com/Roamtech-Solutions/infrastructure/blob/4e1ed2682d5d668a867dba4c00181eec38d52049/.github/matrix/docker-java-spring-boot.json#L1-L8

> Here we can see that a Docker image called `app` will be built from the
> [`docker/java-spring-boot/Dockerfile`](/docker/java-spring-boot/Dockerfile)
> file.

You can  have multiple images, for example see PHP Laravel (`php-laravel`):
https://github.com/Roamtech-Solutions/infrastructure/blob/4e1ed2682d5d668a867dba4c00181eec38d52049/.github/matrix/docker-php-laravel.json#L1-L16

> This builds 3 images, which the service requires:
> - `nginx` for ingress to the application
> - `fpm` for listing for CGI requests from the `nginx` container
> - `cli` for performing migrations and other tasks

This is all that is needed to create new build types in the infrastructure
framework.

## More Information on the GitHub Actions Implementation

GitHub Actions allows for job variations with
[Matrix Strategies][gha-matrix-strats].

There is a generic solution in place in the build and deploy workflow, which
means that all that is needed to get a service type building, is the Dockerfile
and respective build matrix.

Here is where the build type is identified in the main build and deploy
workflow:
https://github.com/Roamtech-Solutions/infrastructure/blob/4e1ed2682d5d668a867dba4c00181eec38d52049/.github/workflows/build-deploy.yaml#L64-L68

We can see here that it is detecting the service type configured in the 
service project and then loading the respective build matrix and saving it
as an output in the workflow step. The job then uses that step output and
makes it available as a job output, so that the next job can access it:
https://github.com/Roamtech-Solutions/infrastructure/blob/4e1ed2682d5d668a867dba4c00181eec38d52049/.github/workflows/build-deploy.yaml#L79-L82

In the `build` job, which runs after the `matrix` job, the matrix strategy
is configured using the output made in the `matrix` job:
https://github.com/Roamtech-Solutions/infrastructure/blob/4e1ed2682d5d668a867dba4c00181eec38d52049/.github/workflows/build-deploy.yaml#L87-L94

Then when it comes to actually building the images, the image name is suffixed
with the `name` (`matrix.name`) property and the `dockerfile`
(`matrix.dockerfile`) property is used to reference which Docerfile to
build with:

https://github.com/Roamtech-Solutions/infrastructure/blob/4e1ed2682d5d668a867dba4c00181eec38d52049/.github/workflows/build-deploy.yaml#L142-L155


<!-- Links -->
[gha-matrix-strats]: https://docs.github.com/en/actions/how-tos/write-workflows/choose-what-workflows-do/run-job-variations

