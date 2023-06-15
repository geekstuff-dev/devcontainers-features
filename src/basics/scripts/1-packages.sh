#!/bin/sh

# Add essential devcontainer packages

if test -z "$COMMON_LOADED"; then
    . "$(dirname "$0")"/.common.sh
fi

if isApk; then
    apk update \
        && apk upgrade \
        && apk add --no-cache \
            bash-completion \
            ca-certificates \
            curl \
            git \
            git-bash-completion \
            gnupg \
            iproute2 \
            jq \
            less \
            libstdc++ \
            make \
            ncurses \
            nano \
            openssh-client \
            openssl \
            procps \
            socat \
            sudo \
            tree \
            unzip \
        && rm -rf /var/cache/apk/*

elif isApt; then
    apt-get update \
        && apt-get -y install --no-install-recommends apt-transport-https apt-utils dialog 2>&1 \
        && rm -rf /var/lib/apt/lists/*

    apt-get update \
        && apt-get -y install \
            bash-completion \
            ca-certificates \
            curl \
            git \
            gpg \
            iproute2 \
            jq \
            less \
            lsb-release \
            make \
            nano \
            openssh-client \
            procps \
            socat \
            tree \
            unzip \
        && rm -rf /var/lib/apt/lists/*
fi

out "[] Basic packages installed"
