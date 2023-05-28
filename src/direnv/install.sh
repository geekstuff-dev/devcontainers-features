#!/bin/sh

# Load http proxy if set in basic feature
if test -e $LIB_DEVCONTAINER_FEATURES/buildtime-http-proxy.sh; then
    . $LIB_DEVCONTAINER_FEATURES/buildtime-http-proxy.sh
fi

# Install direnv

. "$(dirname "$0")"/.common.sh

# vars with default values that can be overriden and comitted to project
requireEnvs "DEV_USERNAME"

# Using .profile here to avoid situation of both a .bashrc and .profile at
# the same time, and somehow only .bashrc gets loaded.
USER_PROFILE=/home/${DEV_USERNAME}/.profile

ensureUserProfile

#LATEST_RELEASE=$(github_latest_release direnv/direnv)
LATEST_RELEASE=v2.32.2

curl -sfL https://github.com/direnv/direnv/releases/download/${LATEST_RELEASE}/direnv.linux-amd64 \
    -o /usr/local/bin/direnv
chmod +x /usr/local/bin/direnv

if ! grep -qo "# direnv" $USER_PROFILE; then
   out "Add direnv to $USER_PROFILE"
   cat <<- "EOF" >> $USER_PROFILE

# direnv
eval "$(direnv hook bash)"
EOF
fi

mkdir -p /home/${DEV_USERNAME}/.config/direnv
cat > /home/${DEV_USERNAME}/.config/direnv/config.toml << 'EOF'
[global]
load_dotenv = false
warn_timeout = "15s"

[whitelist]
prefix = [ "/workspaces", "/workspace" ]
EOF

# Add err function - An easiy and more visible way to throw errors in this scenario
# Example usage:
#   err "my error message" && return 1
cat > /home/${DEV_USERNAME}/.config/direnv/direnvrc << 'EOF'
export ENVRC_ERROR=""
export ENVRC_FIXCMD=""

err() {
    #tput setaf 1 >&2
    tput bold >&2
    #tput smul >&2
    tput setaf 1 >&2
    printf "[error]"

    tput sgr0 >&2

    tput setaf 8 >&2
    tput bold >&2
    #tput setaf 7 >&2
    printf " $1" >&2

    tput sgr0 >&2

    ENVRC_ERROR="$1"

    if test -n "$2"; then
        tput bold >&2
        printf " \`$2\`" >&2
        tput sgr0 >&2
        ENVRC_FIXCMD="$2"
    fi

    printf "\n" >&2
}
EOF

out "[] direnv is installed and configured"
