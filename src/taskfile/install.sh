#!/bin/sh

set -e

# If task is present and its version does not match, delete it and reinstall
CURR_TASK_PATH=$(command -v task || true)
if test -n "$CURR_TASK_PATH"; then
    CURR_TASK_VERSION="v$(task --version)"
    echo "Existing task version: $CURR_TASK_VERSION"
    if test "$CURR_TASK_VERSION" != "$VERSION"; then
        echo "Target version is $VERSION, delete different current version"
        rm -f "$CURR_TASK_PATH"
    fi

    # Also delete auto-completion to get the fresh version
    if test -e /etc/bash_completion.d/010_task; then
        rm -f /etc/bash_completion.d/010_task
    fi
fi

# install if not present
if ! command -v task >/dev/null 2>&1; then
    curl -fsSL https://taskfile.dev/install.sh | sh -s -- -b /usr/local/bin "${VERSION}"
fi

# ensure autocomplete
mkdir -p /etc/bash_completion.d
task --completion bash > /etc/bash_completion.d/010_task
