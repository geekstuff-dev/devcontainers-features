
# Vault CLI (vault-cli)

Installs Hashicorp Vault CLI

## Example Usage

```json
"features": {
    "ghcr.io/geekstuff-dev/devcontainers-features/vault-cli:0": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| vault_addr | If provided, will be exported as VAULT_ADDR in devcontainer ENVs | string | - |
| vault_namespace | If provided, will be exported as VAULT_NAMESPACE in devcontainer ENVs | string | - |
| vault_oidc_path | If provided, will be exported as VAULT_OIDC_PATH in devcontainer ENVs | string | - |
| vault_oidc_role | If provided, will be exported as VAULT_OIDC_ROLE in devcontainer ENVs | string | - |
| version | Vault CLI version | string | 1.12.4 |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/geekstuff-dev/devcontainers-features/blob/main/src/vault-cli/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
