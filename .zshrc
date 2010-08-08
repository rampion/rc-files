export SHELL=/bin/zsh

#use vi-style keybindings
bindkey -v

MANPATH=/opt/local/man/:$MANPATH
PATH=/usr/local/bin:/usr/local/sbin:/opt/local/bin:/opt/local/sbin:/usr/texbin:${PATH:s,/usr/local/bin:,,}:. # add /usr/local/bin and current directory to path
setopt autolist # list ambiguous tab-completions
compctl -c man # use commands as tab-completions for arguments to man
setopt correctall # correct spelling on commands (setopt correct) and arguments
setopt histignoredups # don't save current line if it's the same as the last one
setopt noclobber # don't overwrite existing files (use >! if you still want to)
setopt ignoreeof # don't close the shell on CTRL-D (end-of-file)

if [[ $USER == "root" ]]; then
	PROMPT_CHAR="#"
else
	PROMPT_CHAR=":"
fi

autoload -U colors
colors
function get_color {
	local lc=$'\e[' rc=m	# Standard ANSI terminal escape values
	local sep=""
	local codes=""
	for name in $*[@]; do
		if [[ 0 -lt $name && $name -lt 64 ]]; then
			codes="$codes$sep$name"
		else
			codes="$codes$sep${color[$name]}"
		fi
		sep=";"
	done
	print "$lc$codes$rc"
}

# set up the prompt
# see /usr/share/zsh/4.2.3/functions/colors
if [[ $TERM == "vt100" ]]; then
	# WidgetTerm seems to be able to do faint, though Terminal can't
	local PROMPT_COLOR=`get_color none faint black`
	local RPROMPT_COLOR=`get_color none faint magenta`
	local RPROMPT_PATH_COLOR=`get_color none faint cyan`
else
	local PROMPT_COLOR=`get_color none green`
	local RPROMPT_COLOR=`get_color none magenta`
	local RPROMPT_PATH_COLOR=`get_color none cyan`
fi
local RPROMPT_ERROR_COLOR=`get_color bold red`
PROMPT="%{$PROMPT_COLOR%}%h$PROMPT_CHAR%{$reset_color%} "
RPROMPT="%{$RPROMPT_COLOR%}[%(?..%{$RPROMPT_ERROR_COLOR%}error %?%{$RPROMPT_COLOR%} )%n:%{$RPROMPT_PATH_COLOR%}%40</...<%~%<<%{$RPROMPT_COLOR%}]%{$reset_color%}"

# safety aliases
alias rm="rm -i"
alias cp="cp -i"
alias mv="mv -i"
alias clean="rm -f *~"

#alias cd=pushd
#alias gosh="gosh -I. -A ~/Documents/Code/Scheme"

# set up ls (see man ls)
export CLICOLOR=1
export LSCOLORS=Gxfxcxdxbxegedabagacad

# let escape sequences through in LESS
export LESS="-REX"

# use escape sequences in 'ri'
alias ri="ri -f ansi"

# show line numbers
set number

# ~/.zshrc
# if using GNU screen, let the zsh tell screen what the title and hardstatus
# of the tab window should be.
if [[ $TERM == "screen" ]]; then
	# use the current user as the prefix of the current tab title (since that's
	# fairly important, and I change it fairly often)
  TAB_TITLE_PREFIX='"${USER}$PROMPT_CHAR"'
	# when at the shell prompt, show a truncated version of the current path (with
	# standard ~ replacement) as the rest of the title.
	TAB_TITLE_PROMPT='`echo $PWD | sed "s/^\/Users\//~/;s/^~$USER/~/;s/\/..*\//\/...\//"`'
	# when running a command, show the title of the command as the rest of the
	# title (truncate to drop the path to the command)
	TAB_TITLE_EXEC='$cmd[1]:t'

	# use the current path (with standard ~ replacement) in square brackets as the
	# prefix of the tab window hardstatus.
	TAB_HARDSTATUS_PREFIX='"[`echo $PWD | sed "s/^\/Users\//~/;s/^~$USER/~/"`] "'
	# when at the shell prompt, use the shell name (truncated to remove the path to
	# the shell) as the rest of the title
	TAB_HARDSTATUS_PROMPT='$SHELL:t'
	# when running a command, show the command name and arguments as the rest of
	# the title
	TAB_HARDSTATUS_EXEC='$cmd'

	# tell GNU screen what the tab window title ($1) and the hardstatus($2) should be
  function screen_set()
  {
		#	set the tab window title (%t) for screen
		print -nR $'\033k'$1$'\033'\\\

		# set hardstatus of tab window (%h) for screen
		print -nR $'\033]0;'$2$'\a'
  }
	# called by zsh before executing a command
  function preexec()
  {
		local -a cmd; cmd=(${(z)1}) # the command string
		eval "tab_title=$TAB_TITLE_PREFIX$TAB_TITLE_EXEC"
		eval "tab_hardstatus=$TAB_HARDSTATUS_PREFIX$TAB_HARDSTATUS_EXEC"
		screen_set $tab_title $tab_hardstatus
  }
	# called by zsh before showing the prompt
  function precmd()
  {
		eval "tab_title=$TAB_TITLE_PREFIX$TAB_TITLE_PROMPT"
		eval "tab_hardstatus=$TAB_HARDSTATUS_PREFIX$TAB_HARDSTATUS_PROMPT"
		screen_set $tab_title $tab_hardstatus
  }
fi
