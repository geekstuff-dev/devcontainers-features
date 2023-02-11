#!/bin/sh

set -e

# https://confluence.ubisoft.com/pages/viewpage.action?pageId=1001062810

TMP_DIR=$(mktemp -d)
TARGET="$TMP_DIR/aws-cli.zip"

if ! command -v aws &>/dev/null; then
    curl -fsSL -o $TARGET https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip
    unzip -q -d $TMP_DIR $TARGET
    $TMP_DIR/aws/install
    rm -rf $TMP_DIR
fi

mkdir -p /home/dev/.aws
chown -R dev:dev /home/dev/.aws

cat > /etc/bash_completion.d/aws-cli << EOF
complete -C /usr/local/bin/aws_completer aws
EOF

# ENV vars
echo "" > /etc/profile.d/aws-cli.sh
if test -n "$PROJECT"; then
    echo "export AWS_PROJECT=$PROJECT" >> /etc/profile.d/aws-cli.sh
fi
if test -n "$REGION"; then
    echo "export AWS_REGION=$REGION" >> /etc/profile.d/aws-cli.sh
fi
chmod +x /etc/profile.d/aws-cli.sh
