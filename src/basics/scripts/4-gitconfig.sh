#!/bin/sh

# For fancy users that uses multiple Git identies based
# on gitconfig includeIf.gitdir setting, this breaks
# inside the container since the path is different.
#
# This scripts lets you specify which user.email and
# user.signingkey to use when committing from within a
# devcontainer.

if test -z "$COMMON_LOADED"; then
    . "$(dirname "$0")"/.common.sh
fi

# vars with default values that can be overriden and comitted to project
requireEnvs "DEV_USERNAME"

# Vars that specific users could pass otherwise script is skipped.
# - GIT_EMAIL - this assumes your main gitconfig contains your user.name
# - GIT_SIGNINGKEY - if provided this will also be used for commits

# nothing to do if no GIT_EMAIL defined
if test -z $GIT_EMAIL; then
    return 0
fi

GITCONFIG=/home/${DEV_USERNAME}/.gitconfig-workspace

# add user entry if not already present
if (test -e ${GITCONFIG} && ! grep -qo "\[user\]" ${GITCONFIG}) || \
! test -e ${GITCONFIG}; then
    echo "[] Add gitconfig entry for user"
    echo "[user]" >> ${GITCONFIG}
    if [ -n "$GIT_EMAIL" ]; then
        echo "    email = ${GIT_EMAIL}" >> ${GITCONFIG}
    fi
    if [ -n "$GIT_SIGNINGKEY" ]; then
        echo "    signingkey = ${GIT_SIGNINGKEY}" >> ${GITCONFIG}
    fi
    chown $DEV_USERNAME: ${GITCONFIG}
    chmod go-rwx ${GITCONFIG}

    # vscode copies user ~/.gitconfig file inside the container, it if does not exist already.
    # so what we do here is we add a snippet to container dev user ~/.profile, to add our additional gitconfig
    DEV_PROFILE=/home/${DEV_USERNAME}/.profile
    if (test -e $DEV_PROFILE && ! grep -qo ":/workspace/" $DEV_PROFILE); then
        cat << 'EOF' >> $DEV_PROFILE

# gitconfig-workspace
if (test -e ~/.gitconfig && ! grep -qo ":/workspace/" ~/.gitconfig); then
    git config --global --add includeIf.gitdir/i:/workspace/.path ~/.gitconfig-workspace
fi
EOF
    fi
else
    out "user already there"
fi

out "[] Gitconfig override completed"
