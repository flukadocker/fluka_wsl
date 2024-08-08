#!/bin/bash

echo "uninstalling fluka"
rm -f ~/.fluka/fluka.version
rm -f *fluka*tar.gz
myfluka=`sudo dpkg --list | grep fluka`
sudo apt --purge remove $myfluka
