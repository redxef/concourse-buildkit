# concourse-buildkit

A docker image to build multiarch images on [concourse](https://concourse-ci.org)
since buildx is flakey for me.

Currently only the docker registry is supported.


## parameters

- username: Optional. The username used to log into the registry.
- password: Optional. The password used to log into the registry.
