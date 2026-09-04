#!/bin/sh

set -e

# Load http proxy if set in basic feature
if test -e $LIB_DEVCONTAINER_FEATURES/buildtime-http-proxy.sh; then
    . $LIB_DEVCONTAINER_FEATURES/buildtime-http-proxy.sh
fi

# Install Claude cli
su ${_REMOTE_USER} -c "curl -fsSL https://claude.ai/install.sh | bash"
