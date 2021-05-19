#!/usr/bin/env bash

set -euo pipefail

readonly action="${1:-}"
readonly host="${2:-$(hostname)}"
readonly os=$(awk -F= '/^ID=/ {print $2}' /etc/os-release | tr -d '\n')

if [[ "$os" != "nixos" ]] && [[ "$os" != "debian" ]]; then
    echo "Sorry $os is not tested"
    exit 1
fi

function usage() {
    >&2 echo "USAGE: $0 <action> [hostname]"
}

if [[ -z "${action:-}" ]]; then
    usage
    exit 1
fi

case "${action}" in
    build)
        if [[ $os == "nixos" ]]; then
            nix build ".#nixosConfigurations.${host}.config.system.build.toplevel" --show-trace
        else
            home-manager build --flake ".#${host}" --show-trace
        fi
        ;;
    test)
        if [[ $os == "nixos" ]]; then
            sudo nixos-rebuild --flake ".#${host}" test --show-trace
        else
            >&2 echo test is not support on home-manager
            exit 1
        fi
        ;;
    switch)
        if [[ $os == "nixos" ]]; then
            sudo nixos-rebuild --flake ".#${host}" test --show-trace
        else
            home-manager switch --flake ".#${host}"
        fi
        ;;
    boot)
        if [[ $os == "nixos" ]]; then
            sudo nixos-rebuild --flake ".#${host}" boot --show-trace
        else
            >&2 echo boot is not support on home-manager
            exit 1
        fi
        ;;
    *)
        usage
        exit 1
        ;;
esac
