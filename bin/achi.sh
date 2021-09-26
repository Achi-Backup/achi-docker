#!/usr/bin/env bash

function stopContainer() {
    local _prefix=$1

    printf '%s\n' "[$(date +"%T")] Stopping achi container" >&1

    cd "$(dirname "$0")/../" \
        && docker-compose -p "$_prefix" -f docker-compose.yaml kill \
        && yes | docker-compose -p "$_prefix" -f docker-compose.yaml rm>/dev/null; \
        cd ->/dev/null || true
}

function startContainer() {
    local _prefix=$1

    printf '%s\n' "[$(date +"%T")] Starting achi container" >&1

    cd "$(dirname "$0")/../" \
        && COMPOSE_DOCKER_CLI_BUILD=1 DOCKER_BUILDKIT=1 docker-compose -f docker-compose.yaml -p "$_prefix" build \
        && COMPOSE_DOCKER_CLI_BUILD=1 DOCKER_BUILDKIT=1 docker-compose -f docker-compose.yaml -p "$_prefix" up -d; \
        cd ->/dev/null || true
}

CONTAINERS_PREFIX=achi

shift $(($OPTIND - 1))
COMMAND=$1

if [ -z "$COMMAND" ]; then
    printf '%s\n' "[$(date +"%T")] [ERROR] Command is not provided!"
    exit 1
fi

case $COMMAND in
  up | start)
    stopContainer "$CONTAINERS_PREFIX"
    startContainer "$CONTAINERS_PREFIX"
    ;;

  down | stop)
    stopContainer "$CONTAINERS_PREFIX"
    ;;

  ssh)
    docker exec -it achi bash
    ;;

  *)
    printf '%s\n' "[$(date +"%T")] [ERROR] Invalid command. Valid values are up|start, down|stop, ssh"
    ;;
esac