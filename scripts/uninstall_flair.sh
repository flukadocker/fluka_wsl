#!/bin/bash

echo "uninstalling flair"
rm -f ~/.fluka/flair.version
rm -f *flair*deb
myflair=`sudo dpkg --list | grep flair`
sudo apt --purge remove $myflair
