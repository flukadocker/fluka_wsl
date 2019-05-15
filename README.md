# FLUKA on Windows 10 using WSL
These scripts will set up and install FLUKA on Windows 10 using the Windows Subsystem for Linux (WSL).

The Windows Subsystem for Linux lets developers run GNU/Linux environment - including most command-line tools, utilities, and applications - directly on Windows, unmodified, without the overhead of a virtual machine.

## Requirements
It requires Windows 10 (build: 16299 [2017 Fall update] or greater) and admin rights during installation.

## Installation

### 1. Install Windows Subsystem for Linux
Start a *PowerShell* as *Administrator* and run the following command:

    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux

When the command asks, reboot the PC to finalaze the installation.

### 2. Install Ubuntu Linux from the Microsoft Store
In the *Microsoft Store*, search for *Ubuntu* and click on the *Get* button. The installation will start automatically.

### 3. Initialize Ubuntu
To initialize simply click *Lauch* in the *Microsoft Store*, or find *Ubuntu* in the *Start Menu*.

After a couple minutes it will ask for a new Linux username and password. They can be anything, as they are not related to your Windows credentials.

#### 3.1. Legacy console error
Sometimes you can't enter the new Linux username and password, and the following error message is appearing:

    Unsupported console settings. In order to use this feature the legacy console must be disabled.
    
To solve this, right click on the *Title bar*, and select *Properties*. On the *Options* tab disable the *Use Legacy Console* option, and click *OK*. To apply the change you have to close *Ubuntu*

To restart the initialization, *Ubuntu* has to be reset. To do so search for *Ubuntu* in the *Start Menu*, right click on its icon, and select (*More*) *App settings*. In the new window click the *Reset* button. When the reset is complete close the settings window and restart *Ubuntu*. The initialization will start again, and now you will be able to enter the new Linux username and password.

### 4. Downloading the installation scripts
After setting up the Linux username and password, a Linux prompt appears, and you can run the following command:

    git clone https://github.com/horvathd/fluka_wsl.git

This will download the installation scripts from Github.

Switch to the directory containing the scripts:

    cd fluka_wsl/

### 5. Run the main installation script
Run the installation script:

    ./install.sh

At the beginning of the installation you have to provide your Linux password to be able to run *sudo* commands.

If FLUKA needs to be downloaded, you will pe prompted for your FLUKA ID (fuid-xxxx), and password.

The installation script will automatically do the following steps:
1. Update itself from Github
2. Update Ubuntu packages
3. Install packages required by FLUKA and Flair
4. Set up Ubuntu to be able to run FLUKA and Flair
4. Check the latest version of FLUKA and Flair
5. Download FLUKA and Flair, if necessary
6. Install Flair
7. Compile FLUKA
8. Clean up Ubuntu installation

### 6. Close Ubuntu
To finalize the installation close *Ubuntu*.

### 7. Install Xming
Install the *Public Domain Version* of *Xming* from:

    http://www.straightrunning.com/XmingNotes/

## Running FLUKA

### 1. Start Xming
Search for *Xming* in the *Start Menu* and launch it.

### 2. Start Ubuntu
Search for *Ubuntu* in the *Start Menu* and launch it.

### 3. Run FLUKA and Flair
FLUKA is ready to run from the command line, or you can start Flair with the command:

    flair
    
### 4. Working directory
The hard drives of the PC are available in the

    /mnt/
    
folder. You can work directly there, no need to copy any file into your Linux home directory.

## Updates

### 1. Ubuntu
To keep your *Ubuntu* up to date regurarly run the following commands:

    sudo apt update
    sudo apt upgrade
    
### 2. FLUKA and Flair
When a new version of FLUKA or Flair is released simply rerun the installation script. It will take care of updating FLUKA and Flair. After the update *Ubuntu* needs to be restarted, to finalize the changes.

### 3. Solving problems after update
If there is a problem during or after an update, you can try to delete the `~/.fluka/` folder, the dowloaded FLUKA and Flair packages. After this, rerun the installation script. If the problem still presists, please report it on the FLUKA mailing list.

As final solution you can completely reset *Ubuntu*. For the necessary steps see *Installation / 3.1*.
