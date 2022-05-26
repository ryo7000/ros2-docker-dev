#!/usr/bin/env bash

set -eu -o pipefail

SCRIPTS=$(dirname "$(realpath "$0")")

docker compose -f "${SCRIPTS}/docker-compose.yml" run --rm --name ros2-vim ros2-vim /usr/bin/zsh
