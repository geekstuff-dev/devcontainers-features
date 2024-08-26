#!/bin/bash

set -e

## Load http proxy if set in basic feature
if test -e $LIB_DEVCONTAINER_FEATURES/buildtime-http-proxy.sh; then
    . $LIB_DEVCONTAINER_FEATURES/buildtime-http-proxy.sh
fi

. "$(dirname "$0")"/.common.sh

## ensure real grep for the find_version_from_git_tags function below
if isApk; then
    apk add --update --no-cache grep build-base
    rm -rf /var/cache/apk/*
fi

## Figure precise rust tag from option
TARGET_RUST_VERSION="${VERSION:-"latest"}"
find_version_from_git_tags TARGET_RUST_VERSION "https://github.com/rust-lang/rust" "tags/" "." "false"
test -n "${TARGET_RUST_VERSION}"

## Set ENV vars used only for this script, to install Rust at the system level
# https://github.com/rust-lang/rustup/issues/1085#issuecomment-296604244
# https://github.com/rust-lang/rustup/issues/2383
export RUSTUP_HOME=/usr/local/rust/rustup
export CARGO_HOME=/usr/local/rust/cargo
RUSTUP=/usr/local/rust/cargo/bin/rustup

## Install rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
    | sh -s -- \
        --default-toolchain stable \
        --profile default \
        --no-modify-path \
        --component rust-analysis \
        --component rust-src \
        -y

## Prepare user cargo volume
mkdir -p /home/dev/.cargo
chown -R dev: /home/dev/.cargo

## Write system cargo config file
cat > /usr/local/rust/cargo/config.toml << EOF
[alias]     # command aliases
b = "build"
c = "check"
t = "test"
r = "run"
rr = "run --release"
EOF
chown dev: /usr/local/rust/cargo/config.toml

## Write completions for rustup and cargo
$RUSTUP completions bash rustup > /etc/bash_completion.d/rustup
$RUSTUP completions bash cargo > /etc/bash_completion.d/cargo

## finished
out "[] Rust ${TARGET_RUST_VERSION} is installed"
