#!/bin/sh

if test -n "$BUILDTIME_HTTP_PROXY" || test -n "$BUILDTIME_HTTPS_PROXY"; then
    cat > $LIB_DEVCONTAINER_FEATURES/buildtime-http-proxy.sh << EOF
export HTTP_PROXY="$BUILDTIME_HTTP_PROXY"
export HTTPS_PROXY="$BUILDTIME_HTTPS_PROXY"
export NO_PROXY="$BUILDTIME_NO_PROXY"
export http_proxy="$BUILDTIME_HTTP_PROXY"
export https_proxy="$BUILDTIME_HTTPS_PROXY"
export no_proxy="$BUILDTIME_NO_PROXY"
EOF
fi
