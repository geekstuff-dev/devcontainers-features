#!/bin/sh

# Install starship.rs

. "$(dirname "$0")"/.common.sh

# vars with default values that can be overriden and comitted to project
requireEnvs "DEV_USERNAME"

# Using .profile here to avoid situation of both a .bashrc and .profile at
# the same time, and somehow only .bashrc gets loaded.
USER_PROFILE=/home/${DEV_USERNAME}/.profile

# Install Starship
initialDir="$(pwd)"
mkdir -p /tmp/starship
cd /tmp/starship
curl -ssSL https://starship.rs/install.sh -o install.sh
chmod +x install.sh
$(getCmdPrefix) ./install.sh -y
rm install.sh
cd "$initialDir"
rm -rf /tmp/starship

ensureUserProfile
if ! grep -qo "# Starship.rs" $USER_PROFILE; then
   out "Add Starship.rs to $USER_PROFILE"
   cat <<- "EOF" >> $USER_PROFILE

# Starship.rs
eval "$(starship init bash)"
EOF
fi

mkdir -p /home/${DEV_USERNAME}/.config
cat << 'EOF' > /home/${DEV_USERNAME}/.config/starship.toml
# Inserts a blank line between shell prompts
add_newline = false

[package]
disabled = true

[directory]
truncation_length = 0
truncate_to_repo = false
EOF

chown -R ${DEV_USERNAME}: /home/${DEV_USERNAME}/.config

out "[] starship.rs is installed and configured"
