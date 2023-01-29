#!/bin/sh

# Install direnv

. "$(dirname "$0")"/.common.sh

# vars with default values that can be overriden and comitted to project
requireEnvs "DEV_USERNAME"

# Using .profile here to avoid situation of both a .bashrc and .profile at
# the same time, and somehow only .bashrc gets loaded.
USER_PROFILE=/home/${DEV_USERNAME}/.profile

ensureUserProfile

#LATEST_RELEASE=$(github_latest_release direnv/direnv)
LATEST_RELEASE=v2.32.2

curl -sfL https://github.com/direnv/direnv/releases/download/${LATEST_RELEASE}/direnv.linux-amd64 \
    -o /usr/local/bin/direnv
chmod +x /usr/local/bin/direnv

if ! grep -qo "# direnv" $USER_PROFILE; then
   out "Add direnv to $USER_PROFILE"
   cat <<- "EOF" >> $USER_PROFILE

# direnv
eval "$(direnv hook bash)"
direnv allow /workspaces >/dev/null 2>&1
EOF
fi

mkdir -p /home/${DEV_USERNAME}/.config/direnv
echo '[global]' > /home/dev/.config/direnv/config.toml
echo 'load_dotenv = false' >> /home/${DEV_USERNAME}/.config/direnv/config.toml
echo '' >> /home/${DEV_USERNAME}/.config/direnv/config.toml
echo '[whitelist]' >> /home/${DEV_USERNAME}/.config/direnv/config.toml
echo 'prefix = [ "/workspaces" ]' >> /home/${DEV_USERNAME}/.config/direnv/config.toml

out "[] direnv is installed and configured"
