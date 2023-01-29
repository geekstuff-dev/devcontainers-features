#!/bin/sh

# Sets up VSCode as default linux editor
# Creates VSCode extensions folders

if test -z "$COMMON_LOADED"; then
    . "$(dirname "$0")"/.common.sh
fi

# vars with default values that can be overriden and comitted to project
requireEnvs "DEV_USERNAME"

cat > /etc/profile.d/vscode-default-editor.sh << 'EOF'
export EDITOR="code --wait"
export VISUAL="$EDITOR"
EOF

chmod +x /etc/profile.d/vscode-default-editor.sh

mkdir -p /home/$DEV_USERNAME/.vscode-server/extensions \
        /home/$DEV_USERNAME/.vscode-server-insiders/extensions \
    && chown -R $DEV_USERNAME \
        /home/$DEV_USERNAME/.vscode-server \
        /home/$DEV_USERNAME/.vscode-server-insiders

out "[] VSCode tweaks are applied"
