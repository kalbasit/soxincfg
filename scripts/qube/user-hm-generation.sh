#!/bin/bash

if [[ "$(id -u)" -ne "$(id -u user)" ]]
then
    echo "You must run this script under the user 'user'" >&2
    exit 1
fi

if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
    . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi

if [[ -d /home/user/.local/state/nix/profiles ]] &&
    [[ "$(find /home/user/.local/state/nix/profiles/ -xtype l | wc -l)" -gt 0 ]]
then
    echo "Found dead profile links that will break home-manager activation, going to remove all profiles"
    rm -rf /home/user/.local/state/nix/profiles
fi

/user-hm-generation/activate
