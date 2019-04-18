#!/bin/bash -i

# Update Ubuntu

echo "### - Updating Ubuntu"
sudo apt-get update -y
sudo apt-get upgrade -y

# Check if .fluka folder is exist
if [ ! -e ~/.fluka ]; then
    # Create .fluka folder
    mkdir ~/.fluka
fi

# Check if initial setup was completed
echo "### - Checking initial setup"

if [ ! -e ~/.fluka/install.lock ]; then
    # Run initial setup
    echo "### - Running initial setup"

    # Install necessary packages for FLUKA
    echo "### - Installing necessary packages"
    sudo apt-get install -y make gfortran-8 python tk gnuplot-x11 python-tk \
                            python-numpy python-scipy desktop-file-utils \
                            python-imaging-tk python-pil python-dicom

    # Set up symbolic links
    echo "### - Setting up symbolic links"
    sudo ln -sf /bin/bash /bin/sh
    sudo ln -sf /usr/bin/gcc-8 /usr/bin/gcc
    sudo ln -sf /usr/bin/gfortran-8 /usr/bin/gfortran

    # Create FLUKA directory
    echo "### - Creating FLUKA directory"
    sudo mkdir -p /usr/local/fluka
    mkdir -p ~/.local/share

    # Set up enviroment variables
    echo "### - Setting up enviromental variables"
    echo 'export FLUPRO=/usr/local/fluka' >> ~/.bashrc
    echo 'export FLUFOR=gfortran' >> ~/.bashrc
    echo 'export GFORFLU=gfortran-8' >> ~/.bashrc
    echo 'export DISPLAY=:0' >> ~/.bashrc

    # Flag finished initial setup
    touch ~/.fluka/install.lock

    echo "### - Initial setup finished"
else
    echo "### - Initial setup already done"
fi

# Reload bashrc
echo "### - Reloading enviromental variables"
source ~/.bashrc

# Install Flair
echo "### - Running Flair installation"
./scripts/install_flair.sh

# Install FLUKA
echo "### - Running FLUKA installation"
./scripts/install_fluka.sh

echo "### - Cleaning up Ubuntu"
sudo apt-get autoremove -y
sudo apt-get clean -y
