#!/bin/bash

# Get current FLUKA version from FLUKA website
echo "### - Getting current FLUKA version"
wget_return=$(wget -q http://www.fluka.org/Version.tag)

# Check return status of last command
if [ "$?" -eq 0 ]; then
    # Succesful
    echo "### - Got current FLUKA version"

    # Parse FLUKA version tag
    fluka_current=$(grep "version" Version.tag | awk -F":" '{print $2}' | awk '{print $1}')
    echo "### - Current FLUKA version:" $fluka_current

    # Cleanup
    rm -rf Version.tag
else
    # Failed
    echo "### - Failed to get current FLUKA version"

    # Indicate missing current version
    fluka_current=0
fi

# Check if FLUKA is installed
echo "### - Looking for previous FLUKA installation"
if [ -e ~/.fluka/fluka.version ]; then
    # FLUKA is installed
    echo "### - Found previous FLUKA installation"

    # Read installed FLUKA version
    fluka_installed=$(cat ~/.fluka/fluka.version)
    echo "### - Installed FLUKA version:" $fluka_installed

    # Check if current version is available
    if [ "${fluka_current}" == 0 ]; then
        # Current version is unavailable - assume installed version is current
        echo "### - Current FLUKA version not available"
        fluka_current=$fluka_installed
    fi

    # Compare installed and current versions
    echo "### - Comparing current and installed FLUKA versions"
    if [ ! "${fluka_installed}" == "${fluka_current}" ]; then
        # Different versions
        echo "### - Installed FLUKA version is different from current"

        # Remove installed version
        echo "### - Removing installed FLUKA version"
        rm -rf ~/.fluka/fluka.version
    else
        echo "### - Installed FLUKA version is up to date"
    fi
else
    # Indicate that FLUKA wasn't installed
    fluka_installed=0
fi
echo "### - check if fluka is installed"
# Check if FLUKA is installed
if [ ! -e ~/.fluka/fluka.version ]; then
    echo "### - FLUKA is not installed"
    # FLUKA is not installed

    # Check if current version is available
    if [ "${fluka_current}" == 0 ]; then
        echo "### - Current FLUKA version not available"
        # Current version is unavailable

        # Check if a FLUKA package is in the folder
        echo "### - Looking for FLUKA package"
        package_count=$(ls -1 fluka*.tar.gz | wc -l)

        if [ ${package_count} -gt 0 ]; then
            # One or more fluka package is available
            echo "### - Found one or more FLUKA package, using newest"
            fluka_package=$(ls -1 -t fluka*.tar.gz | head -n 1)
        else
            # No package available
            echo "### - No FLUKA package was found"

            # Exit with error
            echo "### - ERROR:"
            echo "### - Cannot determine current version of FLUKA, try again later"

            exit 1
        fi
    else
        # Current version is available
        echo "### - Current FLUKA version is available"

        # Create short FLUKA version number (without respin)
        fluka_current_short=$(echo  $fluka_current | awk -F"." '{print $1 "." $2}')
        # check installed gfortran version
	
	
        # Create FLUKA package filename
#        fluka_package_short=fluka$fluka_current_short-linux-gfor64bit-8.3-AA.tar.gz
#       fluka_package=fluka$fluka_current-linux-gfor64bit-8.3-AA.tar.gz
        fluka_package_short=fluka$fluka_current_short-linux-gfor64bit-9.3-AA.tar.gz
        fluka_package=fluka$fluka_current-linux-gfor64bit-9.3-AA.tar.gz
        fluka_data=fluka${fluka_current_short}-data.tar.gz
    fi
    echo "### fluka package: " $fluka_package
    # Check if FLUKA package with short is already downloaded
    if [ -e ${fluka_package_short} ]; then
        echo "### - FLUKA package with short version number found"
        # FLUKA package with short name is available

        # Extract Version.tag
        echo "### - Checking FLUKA version number of the package"
        sudo tar -zxf ${fluka_package_short} Version.tag

        # Parse version tag
        fluka_short=$(grep "version" Version.tag | awk -F":" '{print $2}' | awk '{print $1}')

        echo "### - FLUKA package version number:" $fluka_short

        # Delete version tag
        rm Version.tag

        # Compare short and current versions
        if [ "${fluka_short}" == "${fluka_current}" ]; then
            echo "### - FLUKA package version is up to date"
            # Same versions

            # Rename FLUKA package
            mv ${fluka_package_short} ${fluka_package}
        fi
    fi

    # Check if current FLUKA package is already downloaded
    if [ ! -e ${fluka_package} ]; then
        # Current package was not downloaded yet
        echo "### - Downloading FLUKA package"

        # Get FUID from user
        echo -n "### - Your FLUKA ID (fuid-xxxx): "
        read fuid

        # Download FLUKA package
        wget_return=$(wget --user=$fuid --ask-password https://www.fluka.org/packages/${fluka_package_short})

        # Check return status of last command
        if [ $? -eq 0 ]; then
            # Succesful
            echo "### - FLUKA package successfully downloaded"

            # Rename FLUKA package
            mv ${fluka_package_short} ${fluka_package}
        else
            # Failed
            echo "### - Download of FLUKA failed"

            # Restore installed FLUKA version
            if [ ! "${fluka_installed}" == 0 ]; then
                echo "### - Keeping previous FLUKA installation"
                touch ~/.fluka/fluka.version
                echo ${fluka_installed} > ~/.fluka/fluka.version

                # Exit without error
                exit 0
            fi

            # Exit with error
            echo "### - No FLUKA package available, try again later"
            exit 1
        fi
    else
        echo "### - Current FLUKA package found, skipping download"
    fi
    # Check if current FLUKA data is already downloaded
    if [ ! -e ${fluka_data} ]; then
        # Current package was not downloaded yet
        echo "### - Downloading FLUKA data"
        # Get FUID from user
        echo -n "### - Your FLUKA ID (fuid-xxxx): "
        read fuid

        # Download FLUKA package
        wget_return=$(wget --user=$fuid --ask-password https://www.fluka.org/packages/${fluka_data})

        # Check return status of last command
        if [ $? -eq 0 ]; then
            # Succesful
            echo "### - FLUKA data successfully downloaded"

        else
            # Failed
            echo "### - Download of FLUKA data failed"

            # Exit with error
             exit 1
        fi
    else
        echo "### - Current FLUKA data found, skipping download"
    fi

    # Extract FLUKA
    echo "### - Extracting FLUKA package"
    sudo rm -rf /usr/local/fluka/*
    sudo tar -zxf ${fluka_package} -C /usr/local/fluka
    sudo tar -zxf ${fluka_data} -C /usr/local/fluka

    cd /usr/local/fluka

    # Compile FLUKA
    echo "### - Compiling FLUKA"
    sudo -E make
    
    # Fix file ownerships
    sudo chown -R root.root *

    # Fix file permissions
    sudo chmod -R a+rX *

    cd -

    # Check if compilation was successful
    if [ -e /usr/local/fluka/flukahp ]; then
        # Save installed FLUKA version
        echo "### - FLUKA compilation successful"

        # Parse actual version tag
        fluka_actual=$(grep "version" /usr/local/fluka/Version.tag | awk -F":" '{print $2}' | awk '{print $1}')

        echo "### - Actual FLUKA package version number:" $fluka_actual

        touch ~/.fluka/fluka.version
        echo ${fluka_actual} > ~/.fluka/fluka.version
    else
        # Exit with error
        echo "### - FLUKA compilation failed"
        exit 1
    fi
fi
