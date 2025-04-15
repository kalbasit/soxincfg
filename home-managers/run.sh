#!/usr/bin/env bash

set -euo pipefail

readonly action="${1:-}"
readonly host="${2:-$(hostname)}"

if type nom &> /dev/null
then
  BUILDER=nom
else
  BUILDER=nix
fi

readonly BUILDER

case "${action}" in
  build)
    >&2 echo "Building $host"

    $BUILDER build ".#homeConfigurations.${host}.activationPackage" --show-trace
    ;;
  switch)
    >&2 echo "Switching $host"

    home-manager switch --flake ".#${host}"
    $(nix path-info ".#homeConfigurations.${host}.activationPackage")/activate
    ;;
  *)
    usage
    exit 1
    ;;
esac
