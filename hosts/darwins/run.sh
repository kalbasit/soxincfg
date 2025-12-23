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
  build)
    >&2 echo "Building $host"

    $BUILDER build ".#darwinConfigurations.${host}.system" --show-trace
    ;;
  switch)
    >&2 echo "Switching $host"

    # steps taken from https://github.com/LnL7/nix-darwin/blob/8b6ea26d5d2e8359d06278364f41fbc4b903b28a/pkgs/nix-tools/darwin-rebuild.sh

    # 1. build the host
    "$0" build "$host"

    # 2. setup the profile
    profile=/nix/var/nix/profiles/system
    systemConfig="$(readlink -f result)"
    sudo -H nix-env -p "$profile" --set "$systemConfig"

    # 3. call darwin-rebuild activate
    sudo ./result/sw/bin/darwin-rebuild activate
    ;;
  *)
    usage
    exit 1
    ;;
esac
