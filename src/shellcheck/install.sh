#!/bin/sh

set -e

# Load http proxy if set in basic feature
if test -e $LIB_DEVCONTAINER_FEATURES/buildtime-http-proxy.sh; then
    . $LIB_DEVCONTAINER_FEATURES/buildtime-http-proxy.sh
fi

if test -z "$VERSION"; then
    VERSION="v0.10.0"
fi

TMP_DIR=$(mktemp -d)
TARGET="$TMP_DIR/shellcheck.tar.xz"
BIN="$TMP_DIR/shellcheck-${VERSION}/shellcheck"

# install if not present
if ! command -v shellcheck &>/dev/null; then
    curl -fsSL -o $TARGET https://github.com/koalaman/shellcheck/releases/download/v0.10.0/shellcheck-${VERSION}.linux.x86_64.tar.xz
    tar -xf $TARGET -C $TMP_DIR
    install -m a+rx $BIN /usr/local/bin
    rm -rf $TMP_DIR
fi
