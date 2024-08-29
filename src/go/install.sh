#!/bin/bash

set -e

# Load http proxy if set in basic feature
if test -e $LIB_DEVCONTAINER_FEATURES/buildtime-http-proxy.sh; then
    . $LIB_DEVCONTAINER_FEATURES/buildtime-http-proxy.sh
fi

. "$(dirname "$0")"/.common.sh

# ensure real grep for the find_version_from_git_tags function below
if isApk; then
    apk add --update --no-cache grep
    rm -rf /var/cache/apk/*
fi

# figure full version
TARGET_GO_VERSION="${VERSION:-"latest"}"
find_version_from_git_tags TARGET_GO_VERSION "https://go.googlesource.com/go" "tags/go" "." "true"
test -n "${TARGET_GO_VERSION}"

# fetch and install go
curl -fsSL -o /tmp/go.tar.gz "https://golang.org/dl/go${TARGET_GO_VERSION}.linux-amd64.tar.gz"
tar -C /usr/local -xzf /tmp/go.tar.gz
rm /tmp/go.tar.gz

go version

# create system go path + tools
GO=/usr/local/go/bin/go
mkdir -p /go
$GO env -w GOPATH=/go
$GO install golang.org/x/tools/gopls@latest
$GO install gotest.tools/gotestsum@latest
$GO install honnef.co/go/tools/cmd/staticcheck@latest

# golangci-lint
GOLANGCILINT_VERSION="${GOLANGCILINTVERSION:-"latest"}"
if test "$GOLANGCILINT_VERSION" = "latest" || test "$GOLANGCILINT_VERSION" = ""; then
    echo "Installing golangci-lint latest..."
    curl -fsSL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | \
        sh -s -- -b "/go/bin"
else
    echo "Installing golangci-lint ${GOLANGCILINT_VERSION}..."
    curl -fsSL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | \
        sh -s -- -b "/go/bin" "v${GOLANGCILINT_VERSION}"
fi

# create user go path
GO_USER_PATH=/home/dev/go
mkdir -p $GO_USER_PATH
chown -R dev: $GO_USER_PATH

# finished
out "[] Go ${TARGET_GO_VERSION} is installed"
