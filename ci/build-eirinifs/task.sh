#!/bin/bash

set -euo pipefail
export ROOT="$PWD/go/src/github.com/cloudfoundry-incubator"

main(){
  start-docker
  setup-gopath
  build-binaries
  export-eirinifs
  create-checksum-file
}

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

build-binaries() {
  pushd "$ROOT/eirinifs/launchcmd" || exit 1
    GOOS=linux go build -a -o "$ROOT/eirinifs/image/launch"
  popd

  pushd "$ROOT/eirinifs/buildpackapplifecycle/launcher" || exit 1
    echo "package main" > package.go # https://golang.org/cmd/go/#hdr-Import_path_checking
    GOOS=linux CGO_ENABLED=0 go build -a -installsuffix static -o "$ROOT/eirinifs/image/launcher"
  popd
}

export-eirinifs() {
  pushd "$ROOT/eirinifs/image" || exit 1
    docker build -t "eirini/launch" .
    docker run -it -d --name="eirini-launch" eirini/launch /bin/bash
    docker export eirini-launch -o eirinifs.tar
  popd
}

create-checksum-file() {
  shasum -a 256 "$ROOT/eirinifs/image/eirinifs.tar" | awk '{print $1}' > "$ROOT/eirinifs/image/eirinifs.tar.sha256"
}

main "$@"

