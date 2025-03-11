#!/bin/sh

set -e

if command -v apt; then
    # Ideally this would be present at build time in all devcontainers
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install -y dnsutils netcat-openbsd
    rm -rf /var/lib/apt/lists/*
elif command -v apk; then
    apk add --no-cache bind-tools netcat-openbsd
else
    echo "distro not supported"
    exit 1
fi
