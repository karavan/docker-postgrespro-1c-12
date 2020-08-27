#!/bin/sh

docker run --name postgrespro-1c \
  --net host \
  --detach \
  -v /opt/postgresql/data:/data \
  -v /etc/localtime:/etc/localtime:ro \
  --env POSTGRES_PASSWORD=password \
  karavan/docker-postgrespro-1c-12
