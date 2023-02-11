#!/bin/sh

# any command failure will stop execution
set -e

export COMMON_LOADED=1

# set term if not set
if test -z "$TERM"; then
  export TERM=xterm-256color
fi

github_latest_release() {
  # this hits api limits quickly.. :/
  curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/' >&1                                # Pluck JSON value
}

out() {
    if command -v apk > /dev/null 2>&1; then
        echo -e "\e[32m$1\e[0m" >&1
    elif command -v apt > /dev/null 2>&1; then
        echo "\e[32m$1\e[0m" >&1
    else
        echo "$1" >&1
    fi
}

err() {
    if command -v apk > /dev/null 2>&1; then
        echo -e "\e[31m$1\e[0m" >&2
    elif command -v apt > /dev/null 2>&1; then
        echo "\e[31m$1\e[0m" >&2
    else
        echo "$1" >&2
    fi
}

getValue() {
    local envName="$1"
    local envValue=$(printenv $envName)
    local defaultValue="$2"
    if test -n "$envValue"; then
        echo "$envValue"
    else
        echo "$defaultValue"
    fi
}

isApt() {
    if command -v apt > /dev/null 2>&1; then
        return 0
    fi
    return 1
}

isApk() {
    if command -v apk > /dev/null 2>&1; then
        return 0
    fi
    return 1
}

######################################

ensureEnv() {
    local envName="$1"
    local envValue=$(printenv $envName)
    if test -z "$envValue"; then
        return 1
    fi
}

envsPresent() {
    local envs="$1"
    local missing=""
    for envName in $envs; do
        if ! ensureEnv $envName; then
            missing="${missing}\$${envName} "
        fi
    done
    if [ "$missing" != "" ]; then
        return 1
    fi
}

requireEnvs() {
    local envs="$1"
    local missing=""
    for envName in $envs; do
        if ! ensureEnv $envName; then
            missing="${missing}\$${envName} "
        fi
    done
    if [ "$missing" != "" ]; then
        errorOut "Required ENV Vars are missing: ${missing}"
    fi
}

skipIfNotEnabled() {
    local flagName="$1"
    local flagValue=$(printenv $flagName)
    if ! checkEnableFlag $flagName; then
        out "NOT Enabled. Set \`ARG ${flagName}=1\`"
        exit 0
    fi
}

checkEnableFlag() {
    local flagName="$1"
    local flagValue=$(printenv $flagName)
    if test -z $flagValue || [ "$flagValue" != "1" ]; then
        return 1
    fi
}

errorOut() {
    local errorMessage=$1
    local errorCode=$2
    if test -z "$errorCode"; then
        errorCode=1
    fi
    err "Fatal Error ($errorCode) in $0"
    err "$errorMessage"
    exit $errorCode
}

ensureUserProfile() {
    if ! test -e $USER_PROFILE; then
        touch $USER_PROFILE
        chown ${DEV_USERNAME}: $USER_PROFILE
        chmod go-rwx $USER_PROFILE
    fi
}

# build cmdprefix
getCmdPrefix() {
    local ENV_WHITELIST="$1"
    local PREFIX=""

    if [ "$(whoami)" == "root" ]; then
        PREFIX="sudo -u ${DEV_USERNAME}"
        if test -n "$ENV_WHITELIST"; then
            PREFIX="$PREFIX --preserve-env=$ENV_WHITELIST"
        fi

        PREFIX="$PREFIX --"
    fi

    echo $PREFIX
}

# sanity check
if ! isApt && ! isApk; then
    err "Could not detect a valid debian or alpine context"
    exit 2
fi

# set default values
export DEV_USERNAME=$(getValue DEV_USERNAME dev)
export DEV_UID=$(getValue DEV_UID 1000)
export DEV_GID=$(getValue DEV_GID 1000)

# and other values
export DEBIAN_FRONTEND=noninteractive
