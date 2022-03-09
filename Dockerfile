FROM moby/buildkit

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY entrypoint.sh /usr/local/bin/build
ENTRYPOINT [ "entrypoint.sh" ]


