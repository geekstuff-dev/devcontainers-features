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

# Copy scripts
mkdir -p $DEV_LIB_AZURE
cp assets/* $DEV_LIB_AZURE/
chmod -R go+r $DEV_LIB_AZURE
chown -R $DEV_USERNAME: $DEV_LIB_AZURE

if command -v apt; then
    ./install-apt.sh
elif command -v apk; then
    ./install-apk.sh
else
    echo "unsupported distro" && false
fi

#
echo "Azure CLI configured"
