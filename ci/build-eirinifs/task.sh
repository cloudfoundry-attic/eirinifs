#!/bin/bash

set -euo pipefail
export CI_ROOT=$PWD
export ROOT="$PWD/go/src/github.com/cloudfoundry-incubator"
source "eirinifs/ci/scripts/common.sh"

main(){
  start-docker
  setup-gopath
  export-eirinifs
  create-checksum-file
}

export-eirinifs() {
  pushd "$ROOT/eirinifs/image" || exit 1
    cp ${CI_ROOT}/binaries/launcher ./
    cp ${CI_ROOT}/binaries/launch ./
    docker build --build-arg baseimage=${BASEIMAGE} -t "eirini/launch" .
    docker run -it -d --name="eirini-launch" eirini/launch /bin/bash
    docker export eirini-launch -o eirinifs.tar
  popd
}

create-checksum-file() {
  shasum -a 256 "$ROOT/eirinifs/image/eirinifs.tar" | awk '{print $1}' > "$ROOT/eirinifs/image/eirinifs.tar.sha256"
}

main "$@"

