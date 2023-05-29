#!/bin/sh

set -e

# Load http proxy if set in basic feature
if test -e $LIB_DEVCONTAINER_FEATURES/buildtime-http-proxy.sh; then
    . $LIB_DEVCONTAINER_FEATURES/buildtime-http-proxy.sh
fi

# Add rancher cli
TMP_DIR=$(mktemp -d)
TARGET="$TMP_DIR/rancher.tar.gz"
URL="https://github.com/rancher/cli/releases/download/v${VERSION}/rancher-linux-amd64-v${VERSION}.tar.gz"

if ! command -v rancher &>/dev/null; then
    curl -fsSL -o $TARGET "$URL"
    tar -C ${TMP_DIR} -zxvf ${TARGET}
    install -m a+rx -t /usr/local/bin ${TMP_DIR}/rancher-v${VERSION}/rancher
    rm -rf $TMP_DIR
fi
