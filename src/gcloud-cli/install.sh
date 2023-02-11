#!/bin/sh

set -e

DEV_USERNAME=dev

# ENV vars
echo "" > /etc/profile.d/gcloud-cli.sh
if test -n "$PROJECT"; then
    echo "export GCLOUD_PROJECT=$PROJECT" >> /etc/profile.d/gcloud-cli.sh
fi
if test -n "$REGION"; then
    echo "export GCLOUD_REGION=$REGION" >> /etc/profile.d/gcloud-cli.sh
fi
chmod +x /etc/profile.d/gcloud-cli.sh
echo "Wrote ENV vars in [/etc/profile.d/gcloud-cli.sh]"

# Tiny make lib over TF commands
set -eux
mkdir -p $DEV_LIB_GCLOUD
cp scripts/gcloud-cli.mk $DEV_LIB_GCLOUD/gcloud-cli.mk
chmod -R go+r $DEV_LIB_GCLOUD
echo "Wrote TF make lib at [$DEV_LIB_GCLOUD/gcloud-cli.mk]"

# needs python
if ! command -v python 1>/dev/null 2>/dev/null; then
    if command -v apk 1>/dev/null 2>/dev/null; then
        export PYTHONUNBUFFERED=1
        apk add --update --no-cache python3 && ln -sf python3 /usr/bin/python
        python3 -m ensurepip
        pip3 install --no-cache --upgrade pip setuptools
        mkdir -p /etc/bash_completion.d
    elif command -v apt 1>/dev/null 2>/dev/null; then
        apt-get update
        apt-get install -y python3
        rm -rf /var/lib/apt/lists/*
    else
        echo "error: not supported"
        exit 1
    fi
    echo "Python installed"
fi

# install gcloud cli
if ! test -e /home/dev/google-cloud-sdk/bin/gcloud; then
    export CLOUDSDK_CORE_DISABLE_PROMPTS=1
    scratch="$(mktemp -d -t tmp.XXXXXXXXXX)" || exit 1
    script_file="$scratch/install.sh"
    curl https://sdk.cloud.google.com > install.sh
    curl -# "https://sdk.cloud.google.com" > "$script_file" || exit 1
    chmod +x "$script_file"
    chown -R $DEV_USERNAME: $scratch
    sudo --login -u $DEV_USERNAME "$script_file" --disable-prompts
    sudo --login -u $DEV_USERNAME gcloud components install --quiet \
        gke-gcloud-auth-plugin
    rm -rf "$scratch"

    # autocompletion
    ln -s /home/$DEV_USERNAME/google-cloud-sdk/completion.bash.inc /etc/bash_completion.d/gcloud-cli

    # PATH
    cat >> /home/$DEV_USERNAME/.profile << 'EOF'

# Gcloud CLI
. ~/google-cloud-sdk/path.bash.inc
EOF

    mkdir -p /home/$DEV_USERNAME/.config/gcloud
    chown -R $DEV_USERNAME:$DEV_USERNAME /home/$DEV_USERNAME/.config/gcloud
    echo "GCloud CLI installed"
fi

if test "$DOCKER_AUTH" = "true"; then
    echo "[] Setting up gcloud docker auth"
    if ! command -v docker 1>/dev/null 2>/dev/null; then
        echo "Cannot configure DOCKER_AUTH when docker is missing."
        exit 1
    fi
    sudo --login --user=$DEV_USERNAME \
        gcloud auth configure-docker
fi
