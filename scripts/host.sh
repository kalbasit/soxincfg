#!/usr/bin/env bash

set -euo pipefail

readonly action="${1:-}"
readonly host="${2:-$(hostname)}"
readonly os=$(awk -F= '/^ID=/ {print $2}' /etc/os-release | tr -d '\n')

if [[ "$os" != "nixos" ]] && [[ "$os" != "debian" ]] && [[ "$os" != "ubuntu" ]]; then
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
        >&2 echo "Building $host"
        if [[ $os == "nixos" ]]; then
            nix build "path:.#nixosConfigurations.${host}.config.system.build.toplevel"
        else
            nix build "path:.#homeConfigurations.${host}.activationPackage"
        fi
        ;;
    test)
        >&2 echo "Testing $host"
        if [[ $os == "nixos" ]]; then
            nixos-rebuild --use-remote-sudo --flake "path:.#${host}" test # --show-trace
        else
            >&2 echo test is not support on home-manager
            exit 1
        fi
        ;;
    switch)
        >&2 echo "Switching $host"
        if [[ $os == "nixos" ]]; then
            nixos-rebuild --use-remote-sudo --flake "path:.#${host}" switch # --show-trace
        else
            home-manager switch --flake "path:.#${host}"
            $(nix path-info "path:.#homeConfigurations.${host}.activationPackage")/activate
        fi
        ;;
    boot)
        >&2 echo "Booting $host"
        if [[ $os == "nixos" ]]; then
            nixos-rebuild --use-remote-sudo --flake "path:.#${host}" boot # --show-trace
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
