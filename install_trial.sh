#!/bin/bash

# Define installer script's name and path
SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

# Change to scripts directory
cd $SCRIPTPATH

# Update scripts
echo "### - Updating installer scripts"

git checkout master
git pull --force

# Execute installer scripts
echo "### - Starting installation"

exec ./scripts/install_base_trial.sh "$@" >&1 | tee install.log

# Change back to original directory
cd -

echo "### - Installation finished"
