#!/bin/bash
# libdisplay-info #

libdisplay_info=(
    hwdata
)

#specific branch or release
libdisplay_info_tag="0.2.0"

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
# Determine the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_libdisplay-info.log"
MLOG="install-$(date +%d-%H%M%S)_libdisplay-info2.log"

# Installation of dependencies
printf "\n%s - Installing libdisplay-info dependencies.... \n" "${NOTE}"

for PKG1 in "${libdisplay_info[@]}"; do
  install_package "$PKG1" 2>&1 | tee -a "$LOG"
  if [ $? -ne 0 ]; then
    echo -e "\e[1A\e[K${ERROR} - $PKG1 Package installation failed, Please check the installation logs"
    exit 1
  fi
done

# Check if libdisplay-info folder exists and remove it
if [ -d "libdisplay-info" ]; then
    printf "${NOTE} Removing existing libdisplay-info folder...\n"
    rm -rf "libdisplay-info"
fi

# Clone and build 
printf "${NOTE} Installing libdisplay-info...\n"
if git clone --recursive -b $libdisplay_info https://gitlab.freedesktop.org/emersion/libdisplay-info.git; then
    cd libdisplay-info || exit 1
        mkdir -p build && cd $_ && 
        meson setup ..            \
            --prefix /usr/local   \
            --buildtype=release  &&
        ninja 
    if sudo ninja install 2>&1 | tee -a "$MLOG" ; then
        printf "${OK} libdisplay-info installed successfully.\n" 2>&1 | tee -a "$MLOG"
    else
        echo -e "${ERROR} Installation failed for libdisplay-info." 2>&1 | tee -a "$MLOG"
    fi
    #moving the addional logs to Install-Logs directory
    mv $MLOG ../Install-Logs/ || true 
    cd ..
else
    echo -e "${ERROR} Download failed for libdisplay-info." 2>&1 | tee -a "$LOG"
fi

clear
