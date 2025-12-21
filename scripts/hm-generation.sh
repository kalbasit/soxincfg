#! /usr/bin/env bash

set -euo pipefail

readonly here="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
readonly root="$( cd "${here}/.." && pwd )"

if [[ "${#}" -ne 1 ]]; then
    echo "USAGE: $0 <user>"
    exit 1
fi

readonly userName="${1}"

isDarwin() {
	local os="$(uname -s)"
	[[ "${os}" == "Darwin" ]]
}

isLinux() {
	local os="$(uname -s)"
	[[ "${os}" == "Linux" ]]
}

if isLinux; then
    readonly homeManagerService="result/etc/systemd/system/home-manager-${userName}.service"

    if ! [[ -f "${homeManagerService}" ]]; then
        echo "ERR: ${homeManagerService} does not exist"
        exit 1
    fi

    awk '/ExecStart=/ {print $2}' "${homeManagerService}"
elif isDarwin; then
    readonly activation_user="$(awk "/activation-$userName/ {print \$10}" result/activate)"
    readonly activate="$(awk '/exec/ {print $2}' "$activation_user")"
    dirname "$activate"
else
    >&2 echo "OS is not supported"
    exit 1
fi
