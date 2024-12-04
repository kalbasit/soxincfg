#!/usr/bin/env bash

set -euo pipefail

root_dir="$(cd -- "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
readonly root_dir

if [[ "$#" -ne 1 ]]
then
    echo "USAGE: $0 <host>" >&2
    exit 1
fi

host="$1"
readonly host

nom build ".#homeConfigurations.${host}.activationPackage"
