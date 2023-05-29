#!/bin/sh

set -e

# Load http proxy if set in basic feature
if test -e $LIB_DEVCONTAINER_FEATURES/buildtime-http-proxy.sh; then
    . $LIB_DEVCONTAINER_FEATURES/buildtime-http-proxy.sh
fi

# add gas cli to facilitate git management over all repos under a folder
TMP_DIR=$(mktemp -d)
TARGET="$TMP_DIR/gas.tar.gz"
URL="https://github.com/leighmcculloch/gas/releases/download/v${VERSION}/gas_${VERSION}_linux_amd64.tar.gz"

if ! command -v gas &>/dev/null; then
    curl -fsSL -o $TARGET "$URL"
    tar -C ${TMP_DIR} -zxvf ${TARGET}
    install -m a+rx -t /usr/local/bin ${TMP_DIR}/gas_${VERSION}_linux_amd64/gas
    rm -rf $TMP_DIR
fi
