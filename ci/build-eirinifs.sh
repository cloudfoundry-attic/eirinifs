#!/bin/bash

set -xeuo pipefail

start-docker() {
  echo 'DOCKER_OPTS="--data-root /scratch/docker --max-concurrent-downloads 10"' > /etc/default/docker
  service docker start
  trap 'service docker stop' EXIT

  local max_retries=20
  local current_retries=0
  until docker-running; do
    echo "Current docker status: $(service docker status)"
    if [ "$current_retries" -gt "$max_retries" ]; then
        echo "Failed to start docker daemon after $max_retries retries"
        exit 1
    fi
    ((++current_retries))
    sleep 0.5
  done
  echo "Docker started"
}

docker-running() {
  docker stats --no-stream > /dev/null 2>&1
}

mkdir -p go/src/github.com/suhlig
export GOPATH=$PWD/go
export PATH=$PATH:$GOPATH/bin

cp -r eirinifs go/src/github.com/suhlig

start-docker


pushd go/src/github.com/suhlig/eirinifs
BASEDIR="$(pwd)"
echo "package main" > $BASEDIR/buildpackapplifecycle/launcher/package.go

( cd $BASEDIR/launchcmd && GOOS=linux go build -a -o $BASEDIR/image/launch )
( cd $BASEDIR/buildpackapplifecycle/launcher && GOOS=linux CGO_ENABLED=0 go build -a -installsuffix static -o $BASEDIR/image/launcher )

pushd $BASEDIR/image
docker build -t "eirini/launch" .
popd

rm $BASEDIR/image/launch
rm $BASEDIR/image/launcher

docker run -it -d --name="eirini-launch" eirini/launch /bin/bash
docker export eirini-launch -o $BASEDIR/image/eirinifs.tar
docker stop eirini-launch
docker rm eirini-launch
