#!/bin/bash

# Get current Flair version from FLUKA website
echo "### - Getting current Flair version"
wget_return=$(wget -q http://www.fluka.eu/flair/version.tag)

# Check return status of last command
if [ "$?" -eq 0 ]; then
    # Succesful
    echo "### - Got current Flair version"

    # Parse Flair version tag
    flair_current=$(grep "flair*" version.tag | awk '{print $1}' | tail -c +7 | head -c -5)
    echo "### - Current Flair version:" $flair_current

    # Cleanup
    rm -rf version.tag
else
    # Failed
    echo "### - Failed to get current Flair version"

    # Indicate missing current version
    flair_current=0
fi

# Check if Flair is installed
echo "### - Looking for previous Flair installation"
if [ -e ~/.fluka/flair.version ]; then
    # Flair is installed
    echo "### - Found previous Flair installation"

    # Read installed Flair version
    flair_installed=$(cat ~/.fluka/flair.version)
    echo "### - Installed Flair version:" $flair_installed

    # Check if current version is available
    if [ "${flair_current}" == 0 ]; then
        # Current version is unavailable - assume installed version is current
        echo "### - Current Flair version not available"
        flair_current=$flair_installed
    fi

    # Compare installed and current versions
    echo "### - Comparing current and installed Flair versions"
    if [ ! "${flair_installed}" == "${flair_current}" ]; then
        # Different versions
        echo "### - Installed Flair version is different from current"

        # Remove installed version
        echo "### - Removing installed Flair version"
        rm -rf ~/.fluka/flair.version
    else
        echo "### - Installed Flair version is up to date"
    fi
else
    # Indicate that Flair wasn't installed
    flair_installed=0
fi

# Check if Flair is installed
if [ ! -e ~/.fluka/flair.version ]; then
    echo "### - Flair is not installed"
    # Flair is not installed

    # Check if current version is available
    if [ "${flair_current}" == 0 ]; then
        # Current version is unavailable

        # Exit with error
        echo "### - ERROR:"
        echo "### - Cannot determine current version of Flair, try again later"

        exit 1
    else
        # Current version is available
        echo "### - Current Flair version is available"

        # Create Flair package filenames
        flair_package=flair_${flair_current}py3_all.deb
        flair_geoviewer_package=flair-geoviewer_${flair_current}py3_amd64.deb
    fi

    # Check if current Flair package is already downloaded
    if [ ! -e ${flair_package} ]; then
        # Current package was not downloaded yet
        echo "### - Downloading Flair package"

        # Download Flair package
        wget_return=$(wget http://www.fluka.eu/flair/${flair_package})

        # Check return status of last command
        if [ $? -eq 0 ]; then
            # Succesful
            echo "### - Flair package successfully downloaded"
        else
            # Failed
            echo "### - Download of Flair failed"

            # Restore installed Flair version
            if [ ! "${flair_installed}" == 0 ]; then
                echo "### - Keeping previous Flair installation"
                touch ~/.fluka/flair.version
                echo ${flair_installed} > ~/.fluka/flair.version

                # Exit without error
                exit 0
            fi

            # Exit with error
            echo "### - ERROR: Try again later"
            exit 1
        fi
    else
        echo "### - Current Flair package found, skipping download"
    fi

    # Check if current Flair package is already downloaded
    if [ ! -e ${flair_geoviewer_package} ]; then
        # Current package was not downloaded yet
        echo "### - Downloading Flair-geoviewer package"

        # Download Flair-geoviewer package
        wget_return=$(wget http://www.fluka.eu/flair/${flair_geoviewer_package})

        # Check return status of last command
        if [ $? -eq 0 ]; then
            # Succesful
            echo "### - Flair-geoviewer package successfully downloaded"
        else
            # Failed
            echo "### - Download of Flair-geoviewer failed"

            # Restore installed Flair version
            if [ ! "${flair_installed}" == 0 ]; then
                echo "### - Keeping previous Flair installation"
                touch ~/.fluka/flair.version
                echo ${flair_installed} > ~/.fluka/flair.version

                # Exit without error
                exit 0
            fi

            # Exit with error
            echo "### - ERROR: Try again later"
            exit 1
        fi
    else
        echo "### - Current Flair-geoviewer package found, skipping download"
    fi

    # Install Flair and Flair-geoviewer
    echo "### - Installing Flair"
    sudo dpkg -i $flair_package $flair_geoviewer_package
    sudo apt-get install -f -y

    # Check if installation was successful
    if [ $? -eq 0 ]; then
        echo "### - Actual Flair package version number:" $flair_current

        touch ~/.fluka/flair.version
        echo ${flair_current} > ~/.fluka/flair.version
    else
        # Exit with error
        echo "### - Flair installation failed"
        exit 1
    fi
fi
