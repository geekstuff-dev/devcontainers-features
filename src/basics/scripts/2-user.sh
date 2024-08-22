#!/bin/sh

# Create a non-root "dev" user
# Add sudo support

if test -z "$COMMON_LOADED"; then
    . "$(dirname "$0")"/.common.sh
fi

# vars with default values that can be overriden and comitted to project
requireEnvs "DEV_USERNAME"

# vars with default values that can be overridden and comitted to project,
# and should also be overridable by users with their own uncomitted values.
requireEnvs "DEV_UID DEV_GID"

if isApk; then
    addgroup -g $DEV_GID $DEV_USERNAME \
        && adduser --disabled-password -s /bin/bash --uid $DEV_UID -G $DEV_USERNAME $DEV_USERNAME \
        && echo $DEV_USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$DEV_USERNAME \
        && chmod 0440 /etc/sudoers.d/$DEV_USERNAME \
        && mkdir -p /home/${DEV_USERNAME}/.config \
        && chown ${DEV_USERNAME}: /home/${DEV_USERNAME}/.config

elif isApt; then
    # Ubuntu 24.04 decided to pre-create user 1000 in docker images...
    if id ubuntu &>/dev/null; then
        userdel --force --remove ubuntu
    fi

    groupadd --gid $DEV_GID $DEV_USERNAME \
        && useradd -s /bin/bash --uid $DEV_UID --gid $DEV_GID -m $DEV_USERNAME \
        && apt-get update \
        && apt-get install -y sudo \
        && rm -rf /var/lib/apt/lists/* \
        && echo $DEV_USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$DEV_USERNAME \
        && chmod 0440 /etc/sudoers.d/$DEV_USERNAME \
        && mkdir -p /home/${DEV_USERNAME}/.config \
        && chown ${DEV_USERNAME}: /home/${DEV_USERNAME}/.config
fi

# At this point we can assume bash is installed for both
# alpine and debian images, so we only need to fix the alpine
# case most likely
if ! test -e /home/${DEV_USERNAME}/.profile; then
    cat << 'EOF' > /home/${DEV_USERNAME}/.profile
# load bash completion if present
if test -f /etc/profile.d/bash_completion.sh; then
    source /etc/profile.d/bash_completion.sh
fi

# include .bashrc if it exists
if [ -n "$BASH_VERSION" ]; then
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi
EOF
    chown ${DEV_USERNAME}: /home/${DEV_USERNAME}/.profile
fi

if isApk && ! test -e /home/${DEV_USERNAME}/.bashrc; then
    cat << 'EOF' > /home/${DEV_USERNAME}/.bashrc
# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
EOF
    chown ${DEV_USERNAME}: /home/${DEV_USERNAME}/.bashrc
fi

out "[] Dev container user $DEV_USERNAME is configured"
