#!/bin/sh

set -e

cat > /etc/profile.d/tf-backend-gitlab.sh << EOF
export GITLAB_HOST="$INSTANCE_HOST"
export GITLAB_STATE_PROJECT_ID="$STATE_PROJECT_ID"
export GITLAB_STATE_PREFIX="$STATE_PREFIX"
EOF

chmod +x /etc/profile.d/tf-backend-gitlab.sh

mkdir $TF_LIB
cp -R direnv $TF_LIB
cp -R make $TF_LIB
chmod -R go+r $TF_LIB
find $TF_LIB -type d -exec chmod +x {} \;
