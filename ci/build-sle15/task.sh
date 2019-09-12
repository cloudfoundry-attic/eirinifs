#!/bin/bash

set -euo pipefail
export CI_ROOT=$PWD
export ROOT="$PWD/go/src/github.com/cloudfoundry-incubator"
source "eirinifs/ci/scripts/common.sh"

main(){
  start-docker
  setup-gopath
  export-sle15
}

export-sle15() {
  wget $(cat sle15-release/body | grep -o "https:\/\/.*\.tgz") # Get the release tarball
  tar --to-command='tar xfz -' -xvf *.tgz packages/sle15.tgz # Extract the rootfs

  export BASEIMAGE="registry.suse.com/cap/sle15"
  cat rootfs/* | docker import - ${BASEIMAGE}

  pushd "$ROOT/eirinifs/image" || exit 1
    cp ${CI_ROOT}/binaries/* ./
    docker build --build-arg baseimage=${BASEIMAGE} -t "eirini/launch" .
    docker run -it -d --name="eirini-launch" eirini/launch /bin/bash
    docker export eirini-launch -o sle15.tar
  popd
}

main "$@"

