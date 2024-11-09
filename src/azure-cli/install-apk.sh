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

# Add fix: https://github.com/Azure/azure-cli/issues/30102
pip install --force-reinstall -v "azure-mgmt-rdbms==10.2.0b17" --break-system-packages

# Install azure cli
pip install --break-system-packages azure-cli
