#!/bin/bash

source ~/.bashrc

# Get current FLUKA version from FLUKA website
wget_return=$(wget -q http://www.fluka.org/Version.tag)

# Check return status of last command
if [ "$?" -eq 0 ]; then
    # Succesful

    # Parse FLUKA version tag
    fluka_current=$(grep "version" Version.tag | awk -F":" '{print $2}' | awk '{print $1}')

    # Cleanup
    rm -rf Version.tag
else
    # Failed

    # Indicate missing current version
    fluka_current=0
fi

# Check if FLUKA is installed
if [ -e ~/.fluka/fluka.version ]; then
    # FLUKA is installed

    # Read installed FLUKA version
    fluka_installed=$(cat ~/.fluka/fluka.version)

    # Check if current version is available
    if [ "${fluka_current}" == 0 ]; then
        # Current version is unavailable - assume installed version is current
        fluka_current=$fluka_installed
    fi

    # Compare installed and current versions
    if [ ! "${fluka_installed}" == "${fluka_current}" ]; then
        # Different versions

        # Remove installed version
        rm -rf ~/.fluka/fluka.version
    fi
else
    # Indicate that FLUKA wasn't installed
    fluka_installed=0
fi

# Check if FLUKA is installed
if [ ! -e ~/.fluka/fluka.version ]; then
    # FLUKA is not installed

    # Check if current version is available
    if [ "${fluka_current}" == 0 ]; then
        # Current version is unavailable

        # Check if a FLUKA package is in the folder
        package_count=$(ls -1 fluka*.tar.gz | wc -l)

        echo $package_count

        if [ ${package_count} -gt 0 ]; then
            # One or more fluka package is available
            fluka_package=$(ls -1 -t fluka*.tar.gz | head -n 1)

            echo $fluka_package
        else
            # No package available

            # Exit with error
            exit 1
        fi
    else
        # Current version is available

        # Create short FLUKA version number (without respin)
        fluka_current_short=$(echo  $fluka_current | awk -F"." '{print $1 "." $2}')

        # Create FLUKA package filename
        fluka_package_short=fluka$fluka_current_short-linux-gfor64bitAA.tar.gz
        fluka_package=fluka$fluka_current-linux-gfor64bitAA.tar.gz
    fi

    # Check if current FLUKA package is already downloaded
    if [ ! -e ${fluka_package} ]; then
        # Current package wan not downloaded yet

        # Get FUID from user
        echo -n "fuid: "
        read fuid

        # Download FLUKA package
        wget_return=$(wget --user=$fuid --ask-password  https://www.fluka.org/packages/${fluka_package_short})

        # Check return status of last command
        if [ $? -eq 0 ]; then
            # Succesful

            # Rename FLUKA package
            mv ${fluka_package_short} ${fluka_package}
        else
            # Failed

            # Restore installed FLUKA version
            if [ ! "${fluka_installed}" == 0 ]; then
                echo ${fluka_installed} > ~/.fluka/fluka.version

                # Exit with error
                exit 1
            fi

            # Exit with error
            exit 1
        fi
    fi

    # Extract FLUKA
    sudo rm -rf /usr/local/fluka/*
    sudo tar -zxf ${fluka_package} -C /usr/local/fluka

    cd /usr/local/fluka

    # Compile FLUKA
    sudo -E make

    # Fix file permissions
    sudo chmod -R a+rX *

    cd -

    # Save installed FLUKA version
    touch ~/.fluka/fluka.version
    echo ${fluka_current} > ~/.fluka/fluka.version
fi
