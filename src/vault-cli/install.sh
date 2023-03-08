#!/bin/sh
set -e

# install vault if not present already
if ! command -v vault &>/dev/null; then
    TMP_DIR=$(mktemp -d)
    TARGET="${TMP_DIR}/vault.zip"
    URL="https://releases.hashicorp.com/vault/${VERSION}/vault_${VERSION}_linux_amd64.zip"
    BIN_DIR="/usr/bin"
    BIN="${BIN_DIR}/vault"

    curl -fsSL -o ${TARGET} "${URL}"
    unzip -q -d ${TMP_DIR} ${TARGET}
    install -m 755 -t ${BIN_DIR} ${TMP_DIR}/vault
    rm -rf $TMP_DIR

    if command -v apk 1>/dev/null 2>/dev/null; then
        apk add --update --no-cache libcap
        setcap cap_ipc_lock= /usr/sbin/vault
    fi

    cat > /etc/bash_completion.d/vault << EOF
complete -C $BIN vault
EOF
fi

# ENV vars
echo "" > /etc/profile.d/vault-cli.sh
if test -n "$VAULT_ADDR"; then
    echo "export VAULT_ADDR=$VAULT_ADDR" >> /etc/profile.d/vault-cli.sh
fi
if test -n "$VAULT_NAMESPACE"; then
    echo "export VAULT_NAMESPACE=$VAULT_NAMESPACE" >> /etc/profile.d/vault-cli.sh
fi
if test -n "$VAULT_OIDC_PATH"; then
    echo "export VAULT_OIDC_PATH=$VAULT_OIDC_PATH" >> /etc/profile.d/vault-cli.sh
fi
if test -n "$VAULT_OIDC_ROLE"; then
    echo "export VAULT_OIDC_ROLE=$VAULT_OIDC_ROLE" >> /etc/profile.d/vault-cli.sh
fi
chmod +x /etc/profile.d/vault-cli.sh

echo "[] Vault CLI ensured"
