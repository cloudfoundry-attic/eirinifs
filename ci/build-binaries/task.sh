#!/bin/bash

set -euo pipefail
export CI_ROOT=$PWD
export ROOT="$PWD/go/src/github.com/cloudfoundry-incubator"
source "eirinifs/ci/scripts/common.sh"

main(){
  start-docker
  setup-gopath
  build-binaries
}

build-binaries() {
  pushd "$ROOT/eirinifs/launchcmd" || exit 1
    GOOS=linux go build -a -o "$CI_ROOT/binaries/launch"
  popd

  pushd "$ROOT/eirinifs/buildpackapplifecycle/launcher" || exit 1
    echo "package main" > package.go # https://golang.org/cmd/go/#hdr-Import_path_checking
    GOOS=linux CGO_ENABLED=0 go build -a -installsuffix static -o "$CI_ROOT/binaries/launcher"
  popd
}

main "$@"
