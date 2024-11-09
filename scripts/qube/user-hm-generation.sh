#!/bin/bash

if [[ "$(id -u)" -ne "$(id -u user)" ]]
then
	echo "You must run this script under the user 'user'" >&2
	exit 1
fi

if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
    . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi

/user-hm-generation/activate
