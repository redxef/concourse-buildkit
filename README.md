# concourse-buildkit

**DEPRECATED: this resource is no longer needed, the concourse build
task in combination with the registry-image can build and push multiarch
images now.**

A docker image to build multiarch images on [concourse](https://concourse-ci.org).

## parameters

- dest: Required. The output path for the oci image.
- platform: Optional. A comma seperated list of target platforms, default: current platform
- context: The context with which to build.
- manual: Optional. Don't use params and instead supply all arguments via the command line, default: `false`

## Example

To view a simple invocation just look at [pipeline.yml](ci/pipeline.yml).
