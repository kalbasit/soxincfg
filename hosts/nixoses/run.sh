#!/usr/bin/env bash

set -euo pipefail

readonly action="${1:-}"
readonly host="${2:-$(hostname)}"

function usage() {
  >&2 echo "USAGE: $0 <action> [hostname]"
}

if type nom &> /dev/null
then
  BUILDER=nom
else
  BUILDER=nix
fi

readonly BUILDER

case "${action}" in
  boot)
    >&2 echo "Booting $host"

    nixos-rebuild --use-remote-sudo --flake ".#${host}" boot --show-trace
    ;;
  build)
    >&2 echo "Building $host"

    $BUILDER build ".#nixosConfigurations.${host}.config.system.build.toplevel" --show-trace
    ;;
  switch)
    >&2 echo "Switching $host"

    nixos-rebuild --use-remote-sudo --flake ".#${host}" switch --show-trace
    ;;
  test)
    >&2 echo "Testing $host"

    nixos-rebuild --use-remote-sudo --flake ".#${host}" test --show-trace
    ;;
  *)
    usage
    exit 1
    ;;
esac
