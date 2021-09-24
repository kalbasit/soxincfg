#!/usr/bin/env bash
set -euo pipefail

readonly root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd )"

if [[ ! -v IN_NIX_SHELL  ]] || [[ ! -v SOPS_PGP_FP ]]; then
    >&2 echo "FATAL: You must run this from within soxincfg devShell. TIP: Use Direnv to automatically load it for you."
    exit 1
fi

cd "$root_dir"

rm -f ".sops.yaml"

readonly sops_files=($(find . -name '*.sops' -print) $(find . -name '*.sops.*' -print))

cat <<EOF > .sops.yaml
creation_rules:
- pgp: $SOPS_PGP_FP
EOF

for fn in "${sops_files[@]}"; do
    >&2 echo ">>> Updating $fn"
    sops updatekeys -y "$fn"
done

rm -f ".sops.yaml"
