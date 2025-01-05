#!/bin/sh

if test -z "$VERSION"; then
  echo "error: VERSION missing"
  exit 1
fi

curl -fsSL -o /usr/bin/yq "https://github.com/mikefarah/yq/releases/download/v${VERSION}/yq_linux_amd64"
chmod +x /usr/bin/yq
