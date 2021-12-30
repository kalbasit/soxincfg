#! /usr/bin/env bash

set -euo pipefail

readonly here="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
readonly root="$( cd "${here}/.." && pwd )"

if [[ "${#}" -ne 1 ]]; then
    echo "USAGE: $0 <user>"
    exit 1
fi

readonly userName="${1}"
readonly homeManagerService="result/etc/systemd/system/home-manager-${userName}.service"

if ! [[ -f "${homeManagerService}" ]]; then
    echo "ERR: ${homeManagerService} does not exist"
    exit 1
fi

awk '/ExecStart=/ {print $2}' "${homeManagerService}"
