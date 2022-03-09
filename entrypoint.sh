#!/usr/bin/env sh

DOCKER_LOGIN_FILE_TMPL='{
    "auths": {
        "{{REGISTRY_URL}}": {
            "auth": "{{BASE64_UNAME_PW}}"
        }
    }
}'

docker_login() {
    # TODO: detect registry url
    mkdir -p "$HOME/.docker"
    echo "$DOCKER_LOGIN_FILE_TMPL" | \
        sed -e "s|{{BASE64_UNAME_PW}}|$(printf '%s:%s' "$username" "$password" | base64)|g" \
            -e "s|{{REGISTRY_URL}}|https://index.docker.io/v1/|g" \
        > "$HOME/.docker/config.json"
}

if [ -n "$username" ]; then
    docker_login
fi

buildctl-daemonless.sh "$@"
