#!/bin/sh
set -e

# Add essential devcontainer packages

baseDir="$(dirname $0)"
. $baseDir/scripts/.common.sh

. $baseDir/scripts/1-packages.sh
. $baseDir/scripts/2-user.sh
. $baseDir/scripts/3-vscode.sh
. $baseDir/scripts/4-gitconfig.sh
. $baseDir/scripts/5-browser.sh
. $baseDir/scripts/6-completion.sh
. $baseDir/scripts/7-lib-devcontainer.sh
