#!/bin/bash
# xcb-errors #

xcb_errors=(

)

#specific branch or release
xcb_errors_tag="master"

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
# Determine the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_xcb_errors.log"
MLOG="install-$(date +%d-%H%M%S)_xcb_errors2.log"

# Installation of dependencies
printf "\n%s - Installing xcb-errors dependencies.... \n" "${NOTE}"

for PKG1 in "${xcb_errors[@]}"; do
  install_package "$PKG1" 2>&1 | tee -a "$LOG"
  if [ $? -ne 0 ]; then
    echo -e "\e[1A\e[K${ERROR} - $PKG1 Package installation failed, Please check the installation logs"
    exit 1
  fi
done

# Check if xcb-errors folder exists and remove it
if [ -d "xcb-errors" ]; then
    printf "${NOTE} Removing existing xcb-errors folder...\n"
    rm -rf "xcb-errors"
fi

# Clone and build 
printf "${NOTE} Installing xcb-errors...\n"
if git clone --recursive -b $xcb_errors_tag https://gitlab.freedesktop.org/xorg/lib/libxcb-errors.git; then
    cd xcb-errors || exit 1
        ./autogen.sh 
        ./configure
        make 
    if sudo make install 2>&1 | tee -a "$MLOG" ; then
        printf "${OK} xcb-errors installed successfully.\n" 2>&1 | tee -a "$MLOG"
    else
        echo -e "${ERROR} Installation failed for xcb-errors." 2>&1 | tee -a "$MLOG"
    fi
    #moving the addional logs to Install-Logs directory
    mv $MLOG ../Install-Logs/ || true 
    cd ..
else
    echo -e "${ERROR} Download failed for xcb-errors." 2>&1 | tee -a "$LOG"
fi

clear
