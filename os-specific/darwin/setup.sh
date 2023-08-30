#!/usr/bin/env bash
# vim: sw=2 ts=2 sts=0 noet

{ # prevent the script from executing partially downloaded

set -euo pipefail

readonly color_clear="\033[0m"
readonly color_red="\033[0;31m"
readonly color_green="\033[0;32m"

info() {
	>&2 echo -e "[SOXINCFG] ${color_green}${@}${color_clear}"
}

error() {
	>&2 echo -e "[SOXINCFG] ${color_red}${@}${color_clear}"
}

# Prompt for  sudo password & keep alive
# Taken from https://github.com/LnL7/nix-darwin/blob/2412c7f9f98377680418625a3aa7b685b2403107/bootstrap.sh#L77-L83
sudo_prompt(){
	echo "Please enter your password for sudo authentication"
	sudo -k
	sudo echo "sudo authenticaion successful!"
	while true ; do sudo -n true ; sleep 60 ; kill -0 "$$" || exit ; done 2>/dev/null &
}

readonly here="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if ! defaults read com.github.kalbasit.soxincfg bootstrap >/dev/null 2>&1; then
	info "This MacOS machine is not bootstrap, your password is required"

	sudo_prompt

	info "Installing Xcode command line tools"
	if xcode-select --install; then
		echo "Software update menu has now opened, please follow the instructions to get it installed."
		echo "Once the installation is finished, please press Enter"
		read -rn1
	fi

	# download and install Homebrew if it's not installed already
	command -v brew 2>/dev/null || {
		info "Installing HomeBrew"
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	}

	# download and install Nix
	command -v nix 2>/dev/null || {
		info "Installing Nix"
		curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
	}

	# make sure /run exists
	if [[ ! -d /run ]]; then
		printf 'run\tprivate/var/run\n' | sudo tee -a /etc/synthetic.conf
		sudo /System/Library/Filesystems/apfs.fs/Contents/Resources/apfs.util -t || true
	fi

	# Wipe all (default) app icons from the Dock
	# This is only really useful when setting up a new Mac, or if you don’t use
	# the Dock to launch apps.
	defaults write com.apple.dock persistent-apps -array

	# record that we have bootstrapped so we do not try to bootstrap again
	defaults write com.github.kalbasit.soxincfg bootstrap -bool true
fi

# Brew the Brewfile
info "Brewing the Brew file"
while ! brew bundle --file="${here}/Brewfile" --verbose; do
	error "It looks like HomeBrew has failed, retry [y/n]"

	read -r answer
	while [[ -z "${answer}" ]] || ( [[ "${answer}" != "y" ]] && [[ "${answer}" != "n" ]] ); do
		error "I only understand y or n. Please respond with either y or n"
		read -r answer
	done

	if [[ "${answer}" == "n" ]]; then
		break
	fi
done

} # prevent the script from executing partially downloaded
