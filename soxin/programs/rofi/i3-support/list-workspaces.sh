#!/usr/bin/env bash
#
# vim:ft=sh:tabstop=4:shiftwidth=4:softtabstop=4:noexpandtab
#
# Copyright (c) 2010-2020 Wael Nasreddine <wael.nasreddine@gmail.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307,
# USA.
#

containsElement () {
	local e match="$1"
	shift
	for e; do [[ "$e" == "$match" ]] && return 0; done
	return 1
}

function listWorkspaces() {
	local all_workspaces workspaces current_workspace current_profile current_story dir elem file elem

	# get the list of non-focused workspaces
	all_workspaces=( $(@i3-msg_bin@ -t get_workspaces | @jq_bin@ -r '.[] | select(.focused == false) | .name') )

	# get the list of available profiles
	for file in $(find "${HOME}/.zsh/profiles" -iregex '.*/[a-z]*\.zsh' | sort); do
		elem="$(basename "${file}" .zsh)"
		if ! containsElement "${elem}" "${all_workspaces[@]}"; then
			all_workspaces=("${all_workspaces[@]}" "${elem}")
		fi
	done

	# compute the current profile and the current story
	current_workspace="$( @i3-msg_bin@ -t get_workspaces | @jq_bin@ -r '.[] | select(.focused == true) | .name' )"
	if echo "${current_workspace}" | grep -q '@'; then
		current_profile="$( echo "${current_workspace}" | cut -d\@ -f1 )"
		current_story="$( echo "${current_workspace}" | cut -d\@ -f2 )"
	else
		current_profile="${current_workspace}"
	fi

	# get the list of available stories
	if [[ -z "${current_story:-}" ]]; then
		for story in $(swm story list --name-only | grep "^${current_profile}/" | cut -d/ -f2-); do
			elem="${current_profile}@${story}"
			if ! containsElement "${elem}" "${all_workspaces[@]}"; then
				all_workspaces+=("${elem}")
			fi
		done
	fi

	# sort the workspaces by putting first the non-story workspaces followed by the story workspaces
	workspaces=( $(printf "%s\n" "${all_workspaces[@]}" | grep -v '@' | sort) $(printf "%s\n" "${all_workspaces[@]}" | grep '@' | sort) )

	for elem in "${workspaces[@]}"; do
		echo "${elem}"
	done
}
