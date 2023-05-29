#!/bin/sh

set -e

# Load http proxy if set in basic feature
if test -e $LIB_DEVCONTAINER_FEATURES/buildtime-http-proxy.sh; then
    . $LIB_DEVCONTAINER_FEATURES/buildtime-http-proxy.sh
fi

# add gas cli to facilitate git management over all repos under a folder
TMP_DIR=$(mktemp -d)
TARGET="$TMP_DIR/glab.tar.gz"
URL="https://gitlab.com/gitlab-org/cli/-/releases/v${VERSION}/downloads/glab_${VERSION}_Linux_x86_64.tar.gz"

if ! command -v glab &>/dev/null; then
    curl -fsSL -o $TARGET "$URL"
    tar -C ${TMP_DIR} -zxvf ${TARGET}
    install -m a+rx -t /usr/local/bin ${TMP_DIR}/bin/glab
    rm -rf $TMP_DIR
fi

# autocomplete
glab completion -s bash > /etc/bash_completion.d/glab

# ENV vars
touch /etc/profile.d/glab.sh
chmod +x /etc/profile.d/glab.sh
test -z "$GITLAB_HOST" || echo "export GITLAB_HOST=${GITLAB_HOST}" >> /etc/profile.d/glab.sh
test -z "$GITLAB_GROUP" || echo "export GITLAB_GROUP=${GITLAB_GROUP}" >> /etc/profile.d/glab.sh
