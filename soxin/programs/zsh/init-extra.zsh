#####################################################################
# options
#####################################################################

if [[ -o interactive ]]; then
	# If a completion is performed with the cursor within a word, and a full
	# completion is inserted, the cursor is moved to the end of the word. That is,
	# the cursor is moved to the end of the word if either a single match is
	# inserted or menu completion is performed.
	setopt alwaystoend

	# Automatically use menu completion after the second consecutive request for
	# completion, for example by pressing the tab key repeatedly. This option is
	# overridden by MENU_COMPLETE.
	setopt automenu

	# Any parameter that is set to the absolute name of a directory immediately
	# becomes a name for that directory, that will be used by the ‘%~’ and related
	# prompt sequences, and will be available when completion is performed on a
	# word starting with ‘~’. (Otherwise, the parameter must be used in the form
	# ‘~param’ first.).
	setopt autonamedirs

	# Make cd push the old directory onto the directory stack.
	setopt autopushd

	# If this is set, zsh sessions will append their history list to the history
	# file, rather than replace it. Thus, multiple parallel zsh sessions will all
	# have the new entries from their history lists added to the history file, in
	# the order that they exit. The file will still be periodically re-written to
	# trim it when the number of lines grows 20% beyond the value specified by
	# $SAVEHIST (see also the HIST_SAVE_BY_COPY option).
	setopt appendhistory

	# If the argument to a cd command (or an implied cd with the AUTO_CD option
	# set) is not a directory, and does not begin with a slash, try to expand the
	# expression as if it were preceded by a ‘~’ (see Filename Expansion).
	setopt cdablevars

	# If unset, the cursor is set to the end of the word if completion is started.
	# Otherwise it stays there and completion is done from both ends.
	setopt completeinword

	# Save each command’s beginning timestamp (in seconds since the epoch) and the
	# duration (in seconds) to the history file. The format of this prefixed data
	# is:
	#   : <beginning time>:<elapsed seconds>;<command>
	setopt extendedhistory

	# If this option is unset, output flow control via start/stop characters
	# (usually assigned to ^S/^Q) is disabled in the shell’s editor.
	setopt noflowcontrol

	# If the internal history needs to be trimmed to add the current command line,
	# setting this option will cause the oldest history event that has a duplicate
	# to be lost before losing a unique event from the list. You should be sure to
	# set the value of HISTSIZE to a larger number than SAVEHIST in order to give
	# you some room for the duplicated events, otherwise this option will behave
	# just like HIST_IGNORE_ALL_DUPS once the history fills up with unique events.
	setopt histexpiredupsfirst

	# If a new command line being added to the history list duplicates an older
	# one, the older command is removed from the list (even if it is not the
	# previous event).
	setopt hist_ignore_all_dups

	# Do not enter command lines into the history list if they are duplicates of
	# the previous event.
	setopt histignoredups

	# Remove command lines from the history list when the first character on the
	# line is a space, or when one of the expanded aliases contains a leading
	# space. Only normal aliases (not global or suffix aliases) have this
	# behaviour. Note that the command lingers in the internal history until the
	# next command is entered before it vanishes, allowing you to briefly reuse or
	# edit the line. If you want to make it vanish right away without entering
	# another command, type a space and press return.
	setopt histignorespace

	# Whenever the user enters a line with history expansion, don't execute the
	# line directly; instead, perform history expansion and reload the line into
	# the editing buffer.
	setopt histverify

	# This options works like APPEND_HISTORY except that new history lines are
	# added to the $HISTFILE incrementally (as soon as they are entered), rather
	# than waiting until the shell exits. The file will still be periodically
	# re-written to trim it when the number of lines grows 20% beyond the value
	# specified by $SAVEHIST (see also the HIST_SAVE_BY_COPY option).
	setopt incappendhistory

	# Allow comments even in interactive shells.
	setopt interactivecomments

	# This is a login shell. If this option is not explicitly set, the shell
	# becomes a login shell if the first character of the argv[0] passed to the
	# shell is a ‘-’.
	setopt login

	# List jobs in the long format by default.
	setopt longlistjobs

	# Perform implicit tees or cats when multiple redirections are attempted (see
	# Redirection).
	setopt multios

	# On an ambiguous completion, instead of listing possibilities or beeping,
	# insert the first match immediately. Then when completion is requested again,
	# remove the first match and insert the second match, etc. When there are no
	# more matches, go back to the first one again. reverse-menu-complete may be
	# used to loop through the list in the other direction. This option overrides
	# AUTO_MENU.
	setopt nomenucomplete

	# If set, parameter expansion, command substitution and arithmetic expansion
	# are performed in prompts. Substitutions within prompts do not affect the
	# command status.
	setopt promptsubst

	# Don't push multiple copies of the same directory onto the directory stack.
	setopt pushdignoredups

	# Exchanges the meanings of ‘+’ and ‘-’ when used with a number to specify a
	# directory in the stack.
	setopt pushdminus

	# Do not print the directory stack after pushd or popd.
	setopt pushdsilent

	# Have pushd with no arguments act like ‘pushd $HOME’.
	setopt pushdtohome

	# This option both imports new commands from the history file, and also causes
	# your typed commands to be appended to the history file (the latter is like
	# specifying INC_APPEND_HISTORY, which should be turned off if this option is
	# in effect). The history lines are also output with timestamps ala
	# EXTENDED_HISTORY (which makes it easier to find the spot where we left off
	# reading the file after it gets re-written).
	#
	# By default, history movement commands visit the imported lines as well as the
	# local lines, but you can toggle this on and off with the set-local-history
	# zle binding. It is also possible to create a zle widget that will make some
	# commands ignore imported commands, and some include them.
	#
	# If you find that you want more control over when commands get imported, you
	# may wish to turn SHARE_HISTORY off, INC_APPEND_HISTORY or
	# INC_APPEND_HISTORY_TIME (see above) on, and then manually import commands
	# whenever you need them using ‘fc -RI’.
	setopt sharehistory

	# Use the zsh line editor. Set by default in interactive shells connected to a
	# terminal.
	setopt zle
fi

# Direnv shit not working
eval "$(direnv hook zsh)"

#####################################################################
# exports
#####################################################################

# setup fzf
if [[ -o interactive ]]; then
	export ENHANCD_FILTER=@fzf_bin@
fi

# export the code path
export CODE_PATH="@home_path@/code"

if [[ "$OSTYPE" = linux* ]]; then
	# GPG_TTY is needed for gpg with pinentry-curses
	export GPG_TTY="$(tty)"
	# use chromium as the karma's driver
	export CHROME_BIN="$(which chromium)"
fi

# Set MYFS to my filesystem
export MYFS="@home_path@/.local"

# Set the editor
export EDITOR=nvim
export SUDO_EDITOR=nvim

# Set the pager
export PAGER=@bat_bin@
export BAT_PAGER="@less_bin@"

# Set the language support
export LANG=en_US.UTF-8
export LC_ALL="${LANG}"
[[ -n "${LC_CTYPE}" ]] && unset LC_CTYPE

# load the Emscripten environment
pathprepend PATH "/usr/lib/emsdk"

# Anything got installed into MYFS?
pathprepend PATH "${MYFS}/bin"
if [[ -d "${MYFS}" ]]; then
	if [[ -d "${MYFS}/opt" ]]; then
		for dir in ${MYFS}/opt/*/bin; do
			pathappend PATH "${dir}"
		done
	fi

	# Make LD can find our files.
	pathappend LD_LIBRARY_PATH "${MYFS}/lib"
fi

# add any libexec directory
if [[ -d @out_dir@/libexec ]]; then
	for dir in @out_dir@/libexec/*; do
		pathappend PATH "${dir}"
	done
fi

# add cargo
pathprepend PATH "@home_path@/.cargo/bin"

#####################################################################
# colors
#####################################################################

# Defining some color
export FG_CLEAR="\033[0m"

# Regular ForeGround colors
export FG_BLACK="\033[0;30m"
export FG_RED="\033[0;31m"
export FG_GREEN="\033[0;32m"
export FG_YELLOW="\033[0;33m"
export FG_BLUE="\033[0;34m"
export FG_MAGNETA="\033[0;35m"
export FG_CYAN="\033[0;36m"
export FG_WHITE="\033[0;37m"

# Bold ForeGround colors
export FG_BLACK_B="\033[1;30m"
export FG_RED_B="\033[1;31m"
export FG_GREEN_B="\033[1;32m"
export FG_YELLOW_B="\033[1;33m"
export FG_BLUE_B="\033[1;34m"
export FG_MAGNETA_B="\033[1;35m"
export FG_CYAN_B="\033[1;36m"
export FG_WHITE_B="\033[1;37m"

# Background colors
export BG_BLACK="\033[40m"
export BG_RED="\033[41m"
export BG_GREEN="\033[42m"
export BG_YELLOW="\033[43m"
export BG_BLUE="\033[44m"
export BG_MAGNETA="\033[45m"
export BG_CYAN="\033[46m"
export BG_WHITE="\033[47m"

# GOOD, WARN and ERROR colors
export GOOD="${FG_GREEN_B}"
export WARN="${FG_YELLOW_B}"
export ERROR="${FG_RED_B}"

# Find the option for using colors in ls, depending on the version
if [[ -o interactive ]]; then
	if [[ "$OSTYPE" == netbsd* ]]; then
		# On NetBSD, test if "gls" (GNU ls) is installed (this one supports colors);
		# otherwise, leave ls as is, because NetBSD's ls doesn't support -G
		gls --color -d . &>/dev/null && alias ls='gls --color=tty'
	elif [[ "$OSTYPE" == openbsd* ]]; then
		# On OpenBSD, "gls" (ls from GNU coreutils) and "colorls" (ls from base,
		# with color and multibyte support) are available from ports.  "colorls"
		# will be installed on purpose and can't be pulled in by installing
		# coreutils, so prefer it to "gls".
		gls --color -d . &>/dev/null && alias ls='gls --color=tty'
		colorls -G -d . &>/dev/null && alias ls='colorls -G'
	elif [[ "$OSTYPE" == darwin* ]]; then
		# this is a good alias, it works by default just using $LSCOLORS
		ls -G . &>/dev/null && alias ls='ls -G'

		# only use coreutils ls if there is a dircolors customization present ($LS_COLORS or .dircolors file)
		# otherwise, gls will use the default color scheme which is ugly af
		[[ -n "$LS_COLORS" || -f "@home_path@/.dircolors" ]] && gls --color -d . &>/dev/null && alias ls='gls --color=tty'
	else
		# For GNU ls, we use the default ls color theme. They can later be overwritten by themes.
		if [[ -z "$LS_COLORS" ]]; then
			(( $+commands[dircolors] )) && eval "$(dircolors -b)"
		fi

		ls --color -d . &>/dev/null && alias ls='ls --color=tty' || { ls -G . &>/dev/null && alias ls='ls -G' }

		# Take advantage of $LS_COLORS for completion as well.
		zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
	fi
fi

#####################################################################
# completion
#####################################################################

if [[ -o interactive ]]; then
	# allow selection of the item in the autocomplete menu
	zstyle ':completion:*:*:*:*:*' menu select

	zstyle ':completion:*' matcher-list 'm:{a-zA-Z-_}={A-Za-z_-}' 'r:|=*' 'l:|=* r:|=*'

	zstyle ':completion:*' list-colors ''
	zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'

	zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
	zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"

	# disable named-directories autocompletion
	zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories

	# Don't complete uninteresting users
	zstyle ':completion:*:*:*:users' ignored-patterns \
		adm amanda apache at avahi avahi-autoipd beaglidx bin cacti canna \
		clamav daemon dbus distcache dnsmasq dovecot fax ftp games gdm \
		gkrellmd gopher hacluster haldaemon halt hsqldb ident junkbust kdm \
		ldap lp mail mailman mailnull man messagebus  mldonkey mysql nagios \
		named netdump news nfsnobody nobody nscd ntp nut nx obsrun openvpn \
		operator pcap polkitd postfix postgres privoxy pulse pvm quagga radvd \
		rpc rpcuser rpm rtkit scard shutdown squid sshd statd svn sync tftp \
		usbmux uucp vcsa wwwrun xfs '_*'

	# ... unless we really want to.
	zstyle '*' single-ignored show

	# Show dots while doing completion
	expand-or-complete-with-dots() {
		# toggle line-wrapping off and back on again
		[[ -n "$terminfo[rmam]" && -n "$terminfo[smam]" ]] && echoti rmam
		print -Pn "%{%F{red}......%f%}"
		[[ -n "$terminfo[rmam]" && -n "$terminfo[smam]" ]] && echoti smam

		zle expand-or-complete
		zle redisplay
	}
	zle -N expand-or-complete-with-dots
	bindkey "^I" expand-or-complete-with-dots
fi

#####################################################################
# directories
#####################################################################

if [[ -o interactive ]]; then
	alias ..='cd ..'
	alias cd..='cd ..'
	alias cd...='cd ../..'
	alias cd....='cd ../../..'
	alias cd.....='cd ../../../..'
	alias cd/='cd /'

	alias md='mkdir -p'
	alias rd=rmdir
	alias d='dirs -v | head -10'
fi

#####################################################################
# Key bindings
#####################################################################

if [[ -o interactive ]]; then

	# http://zsh.sourceforge.net/Doc/Release/Zsh-Line-Editor.html
	# http://zsh.sourceforge.net/Doc/Release/Zsh-Line-Editor.html#Zle-Builtins
	# http://zsh.sourceforge.net/Doc/Release/Zsh-Line-Editor.html#Standard-Widgets

	# Make sure that the terminal is in application mode when zle is active, since
	# only then values from $terminfo are valid
	if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
		function zle-line-init() {
			echoti smkx
		}
		function zle-line-finish() {
			echoti rmkx
		}
		zle -N zle-line-init
		zle -N zle-line-finish
	fi

	bindkey -v                                            # Use vim key bindings
	export KEYTIMEOUT=1                                   # kill ZSH's lag when ESC is pressed in vim mode

	bindkey '^r' history-incremental-search-backward      # [Ctrl-r] - Search backward incrementally for a specified string. The string may begin with ^ to anchor the search to the beginning of the line.
	if [[ "${terminfo[kpp]}" != "" ]]; then
		bindkey "${terminfo[kpp]}" up-line-or-history       # [PageUp] - Up a line of history
	fi
	if [[ "${terminfo[knp]}" != "" ]]; then
		bindkey "${terminfo[knp]}" down-line-or-history     # [PageDown] - Down a line of history
	fi

	# start typing + [Up-Arrow] - fuzzy find history forward
	[[ "${terminfo[kcuu1]}" != "" ]] && bindkey "${terminfo[kcuu1]}" history-substring-search-up

	# start typing + [Down-Arrow] - fuzzy find history backward
	[[ "${terminfo[kcud1]}" != "" ]] && bindkey "${terminfo[kcud1]}" history-substring-search-down

	if [[ "${terminfo[khome]}" != "" ]]; then
		bindkey "${terminfo[khome]}" beginning-of-line      # [Home] - Go to beginning of line
	fi
	if [[ "${terminfo[kend]}" != "" ]]; then
		bindkey "${terminfo[kend]}"  end-of-line            # [End] - Go to end of line
	fi

	bindkey '^A' beginning-of-line                        # [Ctrl-A] - Go to beginning of line
	bindkey '^E' end-of-line                              # [Ctrl-E] - Go to end of line

	bindkey ' ' magic-space                               # [Space] - do history expansion

	bindkey '^[[1;5C' forward-word                        # [Ctrl-RightArrow] - move forward one word
	bindkey '^[[1;5D' backward-word                       # [Ctrl-LeftArrow] - move backward one word

	if [[ "${terminfo[kcbt]}" != "" ]]; then
		bindkey "${terminfo[kcbt]}" reverse-menu-complete   # [Shift-Tab] - move through the completion menu backwards
	fi

	bindkey '^?' backward-delete-char                     # [Backspace] - delete backward
	if [[ "${terminfo[kdch1]}" != "" ]]; then
		bindkey "${terminfo[kdch1]}" delete-char            # [Delete] - delete forward
	else
		bindkey "^[[3~" delete-char
		bindkey "^[3;5~" delete-char
		bindkey "\e[3~" delete-char
	fi

	# Edit the current command line in $EDITOR
	autoload -U edit-command-line
	zle -N edit-command-line
	bindkey -M vicmd 'e' edit-command-line

	#####################################################################
	# misc
	#####################################################################

	## smart urls
	autoload -U url-quote-magic
	zle -N self-insert url-quote-magic

	## file rename magick
	bindkey "^y" copy-prev-shell-word
fi

#####################################################################
# Profile support
#####################################################################

# TODO: create a Derivation for the profile support. Make it optional and have
# ZSH work with or without it.

if [[ -z "${ACTIVE_PROFILE}" || -z "${ACTIVE_STORY}" ]]; then
	if [[ -n "${DISPLAY}" ]] && have i3-msg; then
		active_workspace="$(i3-msg -t get_workspaces 2>/dev/null | @jq_bin@ -r '.[] | if .focused == true then .name else empty end')"

		if [[ "${active_workspace}" =~ '.*@.*' ]]; then
			[[ -z "${ACTIVE_PROFILE}" ]] && export ACTIVE_PROFILE="$(echo "${active_workspace}" | cut -d@ -f1)"
			[[ -z "${ACTIVE_STORY}" ]] && export ACTIVE_STORY="$(echo "${active_workspace}" | cut -d@ -f2)"
		fi

		unset active_workspace
	fi
fi

# load the active profile only if one is available
if [[ -n "${ACTIVE_PROFILE}" ]] && [[ -r "@home_path@/.zsh/profiles/${ACTIVE_PROFILE}.zsh" ]]; then
	sp "${ACTIVE_PROFILE}"
fi

#####################################################################
# Welcome notes
#####################################################################

if [[ -o interactive ]]; then
	@fortune_bin@ -c
fi
