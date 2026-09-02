#!/bin/sh

set -e

if ! command -v curl 1>/dev/null 2>/dev/null; then
    if command -v apk 1>/dev/null 2>/dev/null; then
        apk add --no-cache curl
    elif command -v apt 1>/dev/null 2>/dev/null; then
        apt-get update
        apt-get install -y curl
        rm -rf /var/lib/apt/lists/*
    fi
fi

curl -vs https://fluxcd.io/install.sh | bash
flux completion bash > /etc/bash_completion.d/fluxcd

# copy assets
mkdir -p $FEAT_GS_FLUXCD
cp assets/* $FEAT_GS_FLUXCD/
