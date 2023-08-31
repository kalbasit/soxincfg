#!/usr/bin/env bash
set -euo pipefail

readonly root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd )"

if [[ ! -v IN_NIX_SHELL ]]; then
    >&2 echo "FATAL: You must run this from within soxincfg devShell. TIP: Use Direnv to automatically load it for you."
    exit 1
fi

cd "$root_dir"

for file in $(grep -lr "\"sops\": {")
do
    sops updatekeys -y "$file"
done
