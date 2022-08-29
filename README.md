# concourse-buildkit

A docker image to build multiarch images on [concourse](https://concourse-ci.org)
since buildx is flakey for me.

Currently only the docker registry is supported.

## parameters

- repository: Required. The repository of the image.
- tag: Optional. The tag for the image, default: `latest`
- additional_tags: Optional. Path to a file containing one additional tag per line.
- dest: Required. The output path for the oci image.
- platform: Optional. A comma seperated list of target platforms, default: current platform
- context: The context with which to build.
- manual: Optional. Don't use params and instead supply all arguments via the command line, default: `false`
- username: Optional. The username used to log into the registry.
- password: Optional. The password used to log into the registry.

## Example

To view a simple invocation just look at [pipeline.yml](ci/pipeline.yml).
