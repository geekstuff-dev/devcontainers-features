#!/bin/sh
set -e

if command -v apk 1>/dev/null 2>/dev/null; then
    apk add --no-cache vault libcap
    mkdir -p /etc/bash_completion.d
    VAULT_BIN=/usr/sbin/vault
elif command -v apt 1>/dev/null 2>/dev/null; then
    apt-get update
    if ! command -v curl 1>/dev/null 2>/dev/null; then
        apt-get install -y curl
    fi
    if ! grep -Rnq 'hashicorp.com' /etc/apt/sources.list*; then
        if test -e /etc/apt/trusted.gpg.d/; then
            curl -sS https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/hashicorp.gpg 1>/dev/null
        else
            curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
        fi
        if ! command -v apt-add-repository 1>dev/null 2>dev/null; then
            apt-get install -y software-properties-common
        fi
        apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
    fi
    apt-get update
    apt-get install -y vault
    rm -rf /var/lib/apt/lists/*
    VAULT_BIN=/usr/bin/vault
fi

setcap -r $VAULT_BIN

cat > /etc/bash_completion.d/vault << EOF
complete -C $VAULT_BIN vault
EOF

echo "[] vault cli installed"
