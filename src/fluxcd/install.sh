#!/bin/sh

set -e

curl -s https://fluxcd.io/install.sh | bash
flux completion bash > /etc/bash_completion.d/fluxcd

# copy assets
mkdir -p $FEAT_GS_FLUXCD
cp assets/* $FEAT_GS_FLUXCD/
