#!/usr/bin/env sh

DEFAULT_DOMAIN=docker.io
LEGACY_DEFAULT_DOMAIN=index.docker.io
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
    login_name="$1"
    if [ -z "$login_name" ]; then
        login_name="$DEFAULT_DOMAIN"
    fi
    if [ "$login_name" = "$DEFAULT_DOMAIN" ]; then
        login_name="$LEGACY_DEFAULT_DOMAIN/v1/"
    fi
    login_name="https://$login_name"
    # TODO: detect registry url
    mkdir -p "$HOME/.docker"
    echo "$DOCKER_LOGIN_FILE_TMPL" | \
        sed -e "s|{{BASE64_UNAME_PW}}|$(printf '%s:%s' "$username" "$password" | base64)|g" \
            -e "s|{{REGISTRY_URL}}|$login_name|g" \
        > "$HOME/.docker/config.json"
}

plain() {
    buildctl-daemonless.sh "$@"
}

split_repo_domain() {
    domain_part="$(echo "$1" | sed -n 's|^\([^/]*\)/.*$|\1|p')"
    other_part="$(echo "$1" | sed -n "s|^$domain_part/\?\(.*\)$|\1|p")"

    if [ -z "$domain_part" ]; then
        domain_part="$DEFAULT_DOMAIN"
        other_part="$other_part"
    elif echo "$domain_part" | grep -Evq '\.|:' && [ "$domain_part" != 'localhost' ]; then
        # ^ docker sourcecode checks if $domain_part == $domain_part.lower() in effect checking if all is lower case
        domain_part="$DEFAULT_DOMAIN"
        other_part="$1" # we deviate here from the reference docker implementation
    fi
    if [ "$domain_part" = "$LEGACY_DEFAULT_DOMAIN" ]; then
        domain_part="$DEFAULT_DOMAIN"
    fi
    if [ "$domain_part" = "$DEFAULT_DOMAIN" ] && echo "$other_part" | grep -vq /; then
        other_part="library/$other_part"
    fi
    echo "$domain_part"
    echo "$other_part"
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
            final_tag="$repository:$line,$final_tag"
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

if [ -n "$username" ]; then
    if [ -z "$password" ]; then
        fail "need to also give password when logging in"
    fi
    if [ -z "$repository" ]; then
        docker_login ''
    else
        docker_login "$(split_repo_domain "$repository" | head -n1)"
    fi
fi

if [ -z "$manual" ]; then
    manual=false
fi

if "$manual"; then
    plain "$@"
else
    build
fi
