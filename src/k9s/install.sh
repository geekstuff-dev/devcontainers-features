#!/bin/sh

set -e

# Load http proxy if set in basic feature
if test -e $LIB_DEVCONTAINER_FEATURES/buildtime-http-proxy.sh; then
    . $LIB_DEVCONTAINER_FEATURES/buildtime-http-proxy.sh
fi

# If K9s present and version does not match, delete it and redownload
CURR_K9S_PATH=$(command -v k9s)
if test -n "$CURR_K9S_PATH"; then
    CURR_K9S_VERSION=$(k9s version -s | grep Version | rev | cut -d' ' -f1 | rev)
    echo "Existing k9s version: $CURR_K9S_VERSION"
    if test "$CURR_K9S_VERSION" != "$VERSION"; then
        echo "Target version is $VERSION, delete different current version"
        rm -f "$CURR_K9S_PATH"
    fi

    # Also delete auto-completion to get the fresh version
    if test -e /etc/bash_completion.d/k9s; then
        rm -f /etc/bash_completion.d/k9s
    fi
fi

TMP_DIR=$(mktemp -d)
TARGET="$TMP_DIR/k9s.tar.gz"
BIN="$TMP_DIR/k9s"

# install if not present
if ! command -v k9s &>/dev/null; then
    curl -fsSL -o $TARGET https://github.com/derailed/k9s/releases/download/${VERSION}/k9s_Linux_amd64.tar.gz
    tar -C $TMP_DIR -zxf $TARGET
    install -m a+rx -t /usr/local/bin $TMP_DIR/k9s
    rm -rf $TMP_DIR
fi

# ensure autocomplete
mkdir -p /etc/bash_completion.d
k9s completion bash > /etc/bash_completion.d/k9s

# copy assets
mkdir -p $FEAT_GS_K9S
cp assets/* $FEAT_GS_K9S/
