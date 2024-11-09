#!/bin/sh

set -e

# ms signing key
if test ! -e /etc/apt/keyrings/microsoft.gpg; then
    mkdir -p /etc/apt/keyrings
    curl -sLS https://packages.microsoft.com/keys/microsoft.asc |
        gpg --dearmor |
        tee /etc/apt/keyrings/microsoft.gpg > /dev/null
    chmod go+r /etc/apt/keyrings/microsoft.gpg
fi

# azure cli repo
if test ! -e /etc/apt/sources.list.d/azure-cli.list; then
    AZ_REPO=$(lsb_release -cs)
    echo "deb [arch=`dpkg --print-architecture` signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" |
        tee /etc/apt/sources.list.d/azure-cli.list
fi

# install azure-cli (az)
if test ! -e /usr/bin/az; then
    apt-get update
    apt-get install -y azure-cli ca-certificates curl apt-transport-https lsb-release gnupg
fi
