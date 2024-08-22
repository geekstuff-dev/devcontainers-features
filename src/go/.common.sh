#!/bin/bash

# any command failure will stop execution
set -e

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

# copied from: https://github.com/devcontainers/features/blob/main/src/go/install.sh
find_version_from_git_tags() {
    local variable_name=$1
    local requested_version=${!variable_name}
    if [ "${requested_version}" = "none" ]; then return; fi
    local repository=$2
    local prefix=${3:-"tags/v"}
    local separator=${4:-"."}
    local last_part_optional=${5:-"false"}
    if [ "$(echo "${requested_version}" | grep -o "." | wc -l)" != "2" ]; then
        local escaped_separator=${separator//./\\.}
        local last_part
        if [ "${last_part_optional}" = "true" ]; then
            last_part="(${escaped_separator}[0-9]+)?"
        else
            last_part="${escaped_separator}[0-9]+"
        fi
        local regex="${prefix}\\K[0-9]+${escaped_separator}[0-9]+${last_part}$"
        local version_list="$(git ls-remote --tags ${repository} | grep -oP "${regex}" | tr -d ' ' | tr "${separator}" "." | sort -rV)"
        if [ "${requested_version}" = "latest" ] || [ "${requested_version}" = "current" ] || [ "${requested_version}" = "lts" ]; then
            declare -g ${variable_name}="$(echo "${version_list}" | head -n 1)"
        else
            set +e
            declare -g ${variable_name}="$(echo "${version_list}" | grep -E -m 1 "^${requested_version//./\\.}([\\.\\s]|$)")"
            set -e
        fi
    fi
    if [ -z "${!variable_name}" ] || ! echo "${version_list}" | grep "^${!variable_name//./\\.}$" > /dev/null 2>&1; then
        echo -e "Invalid ${variable_name} value: ${requested_version}\nValid values:\n${version_list}" >&2
        exit 1
    fi
    echo "${variable_name}=${!variable_name}"
}

# sanity check
if ! isApt && ! isApk; then
    err "Could not detect a valid apt or apk context"
    exit 2
fi

# and other values
export DEBIAN_FRONTEND=noninteractive
