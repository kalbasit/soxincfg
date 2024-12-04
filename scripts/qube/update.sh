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

hm_generation="$(nom build --print-out-paths ".#homeConfigurations.${host}.activationPackage")"
readonly hm_generation

echo "Install the hm generation link and the installation script"
sudo ln -nsf "$hm_generation" /user-hm-generation
sudo cp "$root_dir/scripts/qube/user-hm-generation.sh" /user-hm-generation.sh
sudo chmod +x /user-hm-generation.sh

echo "Deploy the systemd service"
sudo cp "$root_dir/scripts/qube/user-hm-generation.service" /etc/systemd/system
sudo systemctl daemon-reload
sudo systemctl enable user-hm-generation.service

echo "Starting the systemd service"
sudo systemctl start user-hm-generation.service

echo "Show the status"
systemctl status user-hm-generation.service
