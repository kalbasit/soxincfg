#!/usr/bin/env bash

set -euo pipefail

readonly action="${1:-}"
readonly host="${2:-$(hostname)}"

function usage() {
  >&2 echo "USAGE: $0 <action> [hostname]"
}

case "${action}" in
  build)
    >&2 echo "Building $host"

    nix build ".#homeConfigurations.${host}.activationPackage" --show-trace
    ;;
  switch)
    >&2 echo "Switching $host"

    $0 build "$host"
    ./result/activate
    ;;
  *)
    usage
    exit 1
    ;;
esac
