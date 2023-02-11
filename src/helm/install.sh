#!/bin/sh

set -e

# helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
rm ./get_helm.sh

# helm completion
mkdir -p /etc/bash_completion.d
if ! test -e /etc/bash_completion.d/helm; then
    helm completion bash > /etc/bash_completion.d/helm
fi
