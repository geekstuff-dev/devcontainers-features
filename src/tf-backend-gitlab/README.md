
# Terraform backend - Gitlab (tf-backend-gitlab)

Configures the Terraform environment variables for Gitlab managed Terraform Backend

## Example Usage

```json
"features": {
    "ghcr.io/geekstuff-dev/devcontainers-features/tf-backend-gitlab:0": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| instance_host | Enter the Gitlab instance hostname (if not gitlab.com) | string | gitlab.com |
| state_project_id | Enter the Gitlab project ID in which the TF states will be stored | string | - |
| state_prefix | Optional, add prefix to tfstates created using this devcontainer | string | - |

## Customizations

### VS Code Extensions

- `GitLab.gitlab-workflow`



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/geekstuff-dev/devcontainers-features/blob/main/src/tf-backend-gitlab/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
