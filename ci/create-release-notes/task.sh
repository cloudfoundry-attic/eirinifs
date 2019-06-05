#!/bin/bash

set -euo pipefail

readonly RELEASE_NOTES="$PWD/release-notes/notes"

main() {
  touch "$RELEASE_NOTES"
  add-eirinifs-information
  add-cflinuxfs3-image-information
}

add-eirinifs-information() {
  local tag commits
  pushd eirinifs || exit 1
  tag="$(git describe --tags --abbrev=0)"
  commits="$(git log HEAD..."$tag" --format="%H %B%n" | grep -v "Signed")"

  if [[ -n "$commits" ]]; then
      echo "This release includes the following commits:" >> "$RELEASE_NOTES"
      echo "$commits" | sed -e 's/^/  /' >> "$RELEASE_NOTES"
  fi
  popd || exit 1
}

add-cflinuxfs3-image-information() {
  local tag digest
  pushd cflinuxfs3-image || exit 1
  tag="$(cat tag)"
  digest="$(cat digest)"
  {
    echo ""
    echo "This release includes the following cflinuxfs3 image:"
    echo "  Tag: $tag"
    echo "  Digest: $digest"
  } >> "$RELEASE_NOTES"
  popd || exit 1
}

main
