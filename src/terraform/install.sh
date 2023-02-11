#!/bin/bash

set -e

DEV_USERNAME=dev
DEBIAN_FRONTEND=noninteractive

if command -v apk 1>/dev/null 2>/dev/null; then
    mkdir -p /etc/bash_completion.d
elif command -v apt 1>/dev/null 2>/dev/null; then
    if ! command -v curl 1>/dev/null 2>/dev/null; then
        apt-get update
        apt-get install -y curl
    fi
    if ! grep -Rnq 'hashicorp.com' /etc/apt/sources.list*; then
        if test -e /etc/apt/trusted.gpg.d/; then
            curl -sS https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/hashicorp.gpg 1>/dev/null
        else
            curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
        fi
        echo "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
        apt-get update
    fi
    rm -rf /var/lib/apt/lists/*
fi

if ! test -e /etc/bash_completion.d/terraform; then
    cat > /etc/bash_completion.d/terraform << EOF
complete -C /home/$DEV_USERNAME/bin/terraform terraform
EOF
fi

echo "[] terraform installed"

# Add and use Tfswitch to set any TF version we want

if ! test -e /home/$DEV_USERNAME/bin; then
    mkdir -p /home/$DEV_USERNAME/bin
    chown -R $DEV_USERNAME: /home/$DEV_USERNAME/bin
fi

TF_VERSION=${VERSION:-"latest"}

if command -v apk 1>/dev/null 2>/dev/null; then
    apk add --update --no-cache libc6-compat
fi

if ! command -v tfswitch 1>/dev/null 2>/dev/null; then
    if test -z "$TFSWITCH_VERSION"; then
        echo "Cannot continue with empty feature option tfswitch_version."
        echo "  You can find the versions here: https://github.com/warrensbox/terraform-switcher/releases"
        exit 1
    fi
    TMPDIR="$(mktemp -d)"
    mkdir -p "${TMPDIR}"
    cd "${TMPDIR}"
    TARBALL="${TMPDIR}/tfswitch.tar.gz"
    curl -sL -o "$TARBALL" \
        https://github.com/warrensbox/terraform-switcher/releases/download/${TFSWITCH_VERSION}/terraform-switcher_${TFSWITCH_VERSION}_linux_amd64.tar.gz
    tar -xzf "$TARBALL"
    BINDIR=/usr/local/bin
    install -d "${BINDIR}"
    install "${TMPDIR}/tfswitch" "${BINDIR}/"
fi

TFSWITCH_FLAG="--latest"
if test "$TF_VERSION" != "latest"; then
    TFSWITCH_FLAG="$TF_VERSION"
fi

sudo --login --user=$DEV_USERNAME \
    tfswitch \
        --chdir=/home/$DEV_USERNAME \
        --bin=/home/$DEV_USERNAME/bin/terraform \
        $TFSWITCH_FLAG

echo "[] tfswitch installed"
