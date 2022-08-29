#!/usr/bin/env sh

fail() {
    echo "Error:" "$@" 1>&2
    exit 1
}

echo_and_run() {
    echo "$@"
    "$@"
}

plain() {
    buildctl-daemonless.sh "$@"
}

build() {
    if [ -z "$dest" ]; then
        fail "missing argument: dest"
    fi
    if [ -z "$context" ]; then
        context=.
    fi
    if [ -z "$platform" ]; then
        platform=""
    else
        platform="--opt platform=$platform"
    fi

    echo_and_run buildctl-daemonless.sh \
        build \
        --frontend dockerfile.v0 \
        --local context="$context" \
        --local dockerfile="$context" \
        $platform \
        --output type=oci,dest=\""$dest"\"
}

if [ -z "$manual" ]; then
    manual=false
fi

if "$manual"; then
    plain "$@"
else
    build
fi
