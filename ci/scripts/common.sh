#!/bin/bash

start-docker() {
  echo 'DOCKER_OPTS="--data-root /scratch/docker --max-concurrent-downloads 10"' > /etc/default/docker
  service docker start
  trap 'service docker stop' EXIT

  local -r max_retries=20
  local current_retries=0
  until docker-running; do
    if [ "$current_retries" -gt "$max_retries" ]; then
        echo "Failed to start docker daemon after $max_retries retries"
        exit 1
    fi
    ((++current_retries))
    sleep 0.5
  done
}

docker-running() {
  docker stats --no-stream > /dev/null 2>&1
}

setup-gopath() {
  mkdir -p "$ROOT"
  export GOPATH=$PWD/go
  export PATH=$PATH:$GOPATH/bin
  cp -r eirinifs "$ROOT"
}
