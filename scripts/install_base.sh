#!/bin/bash

# Update Ubuntu
sudo apt update -y
sudo apt upgrade -y

# Check if .fluka folder is exist
if [ ! -e ~/.fluka ]; then
    # Create .fluka folder
    mkdir ~/.fluka
fi

# Check if initial setup was completed
if [ ! -e ~/.fluka/install.lock ]; then
    # Run initial setup

    # Install necessary packages for FLUKA
    sudo apt install -y make gfortran-8

    # Set up symbolic links
    sudo ln -sf /bin/bash /bin/sh
    sudo ln -sf /usr/bin/gcc-8 /usr/bin/gcc
    sudo ln -sf /usr/bin/gfortran-8 /usr/bin/gfortran

    # Create FLUKA directory
    sudo mkdir -p /usr/local/fluka

    # Set up enviroment variables
    echo 'export FLUPRO=/usr/local/fluka' >> ~/.bashrc
    echo 'export FLUFOR=gfortran' >> ~/.bashrc
    echo 'export GFORFLU=gfortran-8' >> ~/.bashrc
    echo 'export DISPLAY=:0' >> ~/.bashrc
    source ~/.bashrc

    # Flag finished initial setup
    touch ~/.fluka/install.lock
fi

# Install FLUKA
./install_fluka.sh

sudo apt autoremove -y
sudo apt clean -y
