#!/usr/bin/env bash

set -euo pipefail

readonly soxin_path="$(readlink -f ../../SoxinOS/soxin)"

if [[ ! -d "$soxin_path" ]]; then
    >&2 echo "ERR: $soxin_path does not exist. Did you create the project?"
    exit 1
fi

ln -s "$soxin_path" soxin
nix flake update --override-input soxin path:./soxin
