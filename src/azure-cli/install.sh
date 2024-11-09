#!/bin/sh

set -e

# Load http proxy if set in basic feature
if test -e $LIB_DEVCONTAINER_FEATURES/buildtime-http-proxy.sh; then
    . $LIB_DEVCONTAINER_FEATURES/buildtime-http-proxy.sh
fi

DEV_USERNAME=dev

# default azure config dir
mkdir -p /home/${DEV_USERNAME}/.azure
chown -R ${DEV_USERNAME}: /home/${DEV_USERNAME}/.azure

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

# Copy scripts
mkdir -p $DEV_LIB_AZURE
cp assets/* $DEV_LIB_AZURE/
chmod -R go+r $DEV_LIB_AZURE
chown -R $DEV_USERNAME: $DEV_LIB_AZURE
#
echo "Azure CLI configured"
