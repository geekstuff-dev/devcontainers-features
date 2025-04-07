#!/bin/sh

set -e

# Load http proxy if set in basic feature
if test -e $LIB_DEVCONTAINER_FEATURES/buildtime-http-proxy.sh; then
    . $LIB_DEVCONTAINER_FEATURES/buildtime-http-proxy.sh
fi

TMP_DIR=$(mktemp -d)
TMP_BIN="$TMP_DIR/kubectl"

if ! command -v kubectl &>/dev/null; then
    curl -fsSL -o $TMP_BIN https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
    install -m a+rx -t /usr/local/bin $TMP_BIN
fi

mkdir -p /home/dev/.kube
chown -R dev:dev /home/dev/.kube

# Add k alias
echo 'alias k=kubectl' > /etc/profile.d/kubectl-alias.sh
chmod +x /etc/profile.d/kubectl-alias.sh

# Add autocompletion for both kubectl and k alias
mkdir -p /etc/bash_completion.d
kubectl completion bash > /etc/bash_completion.d/kubectl
echo 'complete -o default -F __start_kubectl k' >> /etc/bash_completion.d/kubectl
