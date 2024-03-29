#!/bin/sh

# Load http proxy if set in basic feature
if test -e $LIB_DEVCONTAINER_FEATURES/buildtime-http-proxy.sh; then
    . $LIB_DEVCONTAINER_FEATURES/buildtime-http-proxy.sh
fi

# Install docker and setup docker group(s)

# NOTE on docker, docker sock and docker group ID
#
# When using docker within docker/devcontainer, you must mount a docker sock as a volume.
# To be able to use that docker sock when mounted inside a container, we must create a
# a docker group inside our container, ensure that group matches the group ID of that
# docker sock, and make your container user part of that container docker group.
#
# In Debian/Ubuntu this is usually group ID 998, but in WSL2\Windows this becomes 999 for
# some annoying reason.
#
# Here we get around that by creating 2 groups:
# - docker:998
# - docker2:999
#
# And if a user needs a different port, we are exposing a param to let user override
# that for himself. In this case we create a single docker group with that ID.
#   DOCKER_GID

. "$(dirname "$0")"/.common.sh

if isApk; then
    apk update
    apk add --no-cache docker shadow
    rm -rf /var/cache/apk/*
elif isApt; then
    apt-get update
    apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common lsb-release
    curl -fsSL https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]')/gpg | (OUT=$(apt-key add - 2>&1) || echo $OUT)
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]') $(lsb_release -cs) stable"
    apt-get update
    apt-get install -y docker-ce-cli
    rm -rf /var/lib/apt/lists/*
fi

if test -n "$DOCKER_GID"; then
    # user provided values
    groupadd -g $DOCKER_GID docker
    usermod -aG docker $DEV_USERNAME
else
    # handle 998 docker group
    if ! getent group 998 1>/dev/null 2>/dev/null; then
        if isApk; then
            # not sure why alpine has this ping group there.
            groupmod -g 998 docker
        elif isApt; then
            groupadd -g 998 docker
        fi
    fi
    usermod -aG 998 $DEV_USERNAME

    # handle 999 docker group
    if ! getent group 999 1>/dev/null 2>/dev/null; then
        if isApk; then
            groupmod -g 999 docker2
        elif isApt; then
            groupadd -g 999 docker2
        fi
    fi
    usermod -aG 999 $DEV_USERNAME
fi

# ensure docker folder
mkdir -p /home/$DEV_USERNAME/.docker
test -e /home/$DEV_USERNAME/.docker/config.json \
    || echo "{}" > /home/$DEV_USERNAME/.docker/config.json
chown -R $DEV_USERNAME: /home/$DEV_USERNAME/.docker


out "[] docker is installed"
