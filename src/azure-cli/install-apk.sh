#!/bin/sh

set -e

# Dependencies
apk add --update --no-cache \
    cargo \
    gcc \
    libffi-dev \
    make \
    musl-dev \
    openssl-dev \
    py3-pip \
    python3-dev

# Add fix for a missing module:
#   https://github.com/Azure/azure-cli/issues/30102
pip install --force-reinstall -v "azure-mgmt-rdbms==10.2.0b17" --break-system-packages

# Install azure cli
pip install --break-system-packages azure-cli

# Try to add az cli auto-completion, which is sadly missing with this install method
test -e /etc/bash_completion.d
if ! test -e /etc/bash_completion.d/azure-cli; then
    curl -fsSL \
        -o /etc/bash_completion.d/azure-cli \
        https://raw.githubusercontent.com/Azure/azure-cli/refs/heads/dev/az.completion \
        || echo "failed to patch auto-complete (and not worth erroring out)"
fi
