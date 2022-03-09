#!/usr/bin/env sh

DOCKER_LOGIN_FILE_TMPL='{
    "auths": {
        "{{REGISTRY_URL}}": {
            "auth": "{{BASE64_UNAME_PW}}"
        }
    }
}'

fail() {
    echo "Error:" "$@" 1>&2
    exit 1
}

echo_and_run() {
    echo "$@"
    "$@"
}

docker_login() {
    # TODO: detect registry url
    mkdir -p "$HOME/.docker"
    echo "$DOCKER_LOGIN_FILE_TMPL" | \
        sed -e "s|{{BASE64_UNAME_PW}}|$(printf '%s:%s' "$username" "$password" | base64)|g" \
            -e "s|{{REGISTRY_URL}}|https://index.docker.io/v1/|g" \
        > "$HOME/.docker/config.json"
}

if [ -n "$username" ]; then
    if [ -z "$password" ]; then
        fail "need to also give password when logging in"
    fi
    docker_login
fi

plain() {
    buildctl-daemonless.sh "$@"
}

build() {
    if [ -z "$repository" ]; then
        fail "missing argument: repository"
    fi
    if [ -z "$tag" ]; then
        tag=latest
    fi
    if [ -z "$push" ]; then
        push=false
    fi
    if [ -z "$context" ]; then
        context=.
    fi
    if [ -z "$platform" ]; then
        platform=""
    else
        platform="--opt platform=$platform"
    fi

    final_tag="$repository:$tag"
    if [ -n "$additional_tags" ]; then
        while read -r line; do
            if [ -z "$line" ]; then
                continue
            fi
            final_tag="$final_tag,$repository:$line"
        done < "$additional_tags"
    fi

    echo_and_run buildctl-daemonless.sh \
        build \
        --frontend dockerfile.v0 \
        --local context="$context" \
        --local dockerfile="$context" \
        $platform \
        --output type=image,\"name="$final_tag"\",push="$push"
}

if [ -z "$manual" ]; then
    manual=false
fi

if "$manual"; then
    plain "$@"
else
    build
fi
