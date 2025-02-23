#!/usr/bin/env bash

set -euo pipefail

readonly action="${1:-}"
readonly host="${2:-$(hostname)}"

readonly root_dir="$(cd $(dirname "$BASH_SOURCE[0]")/.. && pwd)"

isDarwin() {
	local os="$(uname -s)"
	[[ "${os}" == "Darwin" ]]
}

isLinux() {
	local os="$(uname -s)"
	[[ "${os}" == "Linux" ]]
}

isNixOS() {
	has nixos-version
}

# Usage: has <command>
#
# Returns 0 if the <command> is available. Returns 1 otherwise. It can be a
# binary in the PATH or a shell function.
#
# Example:
#
#    if has curl; then
#      echo "Yes we do"
#    fi
#
has() {
	type "$1" &>/dev/null
}

isSupported() {
    isNixOS && return 0
    isDarwin && return 0

    if [[ -f /etc/os-release ]]; then
        local os="$(awk -F= '/^ID=/ {print $2}' /etc/os-release | tr -d '\n')"
        case "$os" in
            nixos|debian|ubuntu)
                return 0
                ;;
            *)
                return 1
                ;;
        esac
    fi

    return 1
}

function usage() {
    >&2 echo "USAGE: $0 <action> [hostname]"
}

if ! isSupported; then
    echo "Sorry, your operating system is not supported"
    exit 1
fi

if [[ -z "${action:-}" ]]; then
    usage
    exit 1
fi

case "${action}" in
    build)
        >&2 echo "Building $host"
        if isNixOS; then
            nom build ".#nixosConfigurations.${host}.config.system.build.toplevel"
        elif isDarwin; then
            nom build ".#darwinConfigurations.${host}.system" --show-trace
        else
            nom build ".#homeConfigurations.${host}.activationPackage"
        fi
        ;;
    test)
        >&2 echo "Testing $host"
        if isNixOS; then
            nixos-rebuild --use-remote-sudo --flake ".#${host}" test # --show-trace
        elif isDarwin; then
            >&2 echo test is not support on nix-darwin
            exit 1
        else
            >&2 echo test is not support on home-manager
            exit 1
        fi
        ;;
    switch)
        >&2 echo "Switching $host"
        if isNixOS; then
            nixos-rebuild --use-remote-sudo --flake ".#${host}" switch # --show-trace
        elif isDarwin; then
            # steps taken from https://github.com/LnL7/nix-darwin/blob/8b6ea26d5d2e8359d06278364f41fbc4b903b28a/pkgs/nix-tools/darwin-rebuild.sh

            # 1. build the host
            "$0" build "$host"

            # 2. setup the profile
            profile=/nix/var/nix/profiles/system
            systemConfig="$(readlink -f result)"
            sudo -H nix-env -p "$profile" --set "$systemConfig"

            # 3. call darwin-rebuild activate
            ./result/sw/bin/darwin-rebuild activate
        else
            home-manager switch --flake ".#${host}"
            $(nix path-info ".#homeConfigurations.${host}.activationPackage")/activate
        fi
        ;;
    boot)
        >&2 echo "Booting $host"
        if isNixOS; then
            nixos-rebuild --use-remote-sudo --flake ".#${host}" boot # --show-trace
        elif isDarwin; then
            >&2 echo boot is not support on nix-darwin
            exit 1
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
