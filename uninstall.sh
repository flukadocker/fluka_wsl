#!/bin/bash

# Define installer script's name and path
SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

	 
# Change to scripts directory
cd $SCRIPTPATH
QUALE=$1
QUALE=${QUALE^^}
echo $QUALE
if [ -z "$QUALE" ] ; then
   exec ./scripts/uninstall_flair.sh
   exec ./scripts/uninstall_fluka.sh
elif [ "$QUALE" == "FLUKA" ]; then
	exec ./scripts/uninstall_fluka.sh
elif [ "$QUALE" == "FLAIR" ]; then
	exec ./scripts/uninstall_flair.sh
fi
	
