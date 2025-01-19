#!/bin/bash
# wayland #

wayland=(
    build-essential 
    pkg-config 
    libexpat1-dev 
    libffi-dev 
    ninja-build
)

#specific branch or release
wayland_tag="1.23.1"

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
# Determine the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_wayland.log"
MLOG="install-$(date +%d-%H%M%S)_wayland2.log"

# Installation of dependencies
printf "\n%s - Installing wayland dependencies.... \n" "${NOTE}"

for PKG1 in "${wayland[@]}"; do
  install_package "$PKG1" 2>&1 | tee -a "$LOG"
  if [ $? -ne 0 ]; then
    echo -e "\e[1A\e[K${ERROR} - $PKG1 Package installation failed, Please check the installation logs"
    exit 1
  fi
done

# Check if wayland folder exists and remove it
if [ -d "wayland" ]; then
    printf "${NOTE} Removing existing wayland folder...\n"
    rm -rf "wayland"
fi

# Clone and build 
printf "${NOTE} Installing wayland...\n"
if git clone --recursive -b $wayland_tag https://gitlab.freedesktop.org/wayland/wayland.git; then
    cd wayland || exit 1
        mkdir -p build && cd $_ && 
        meson setup ..            \
            --prefix /usr/local   \
            --buildtype=release   \
            -Ddocumentation=false &&
        ninja 
    if sudo ninja install 2>&1 | tee -a "$MLOG" ; then
        printf "${OK} wayland installed successfully.\n" 2>&1 | tee -a "$MLOG"
    else
        echo -e "${ERROR} Installation failed for wayland." 2>&1 | tee -a "$MLOG"
    fi
    #moving the addional logs to Install-Logs directory
    mv $MLOG ${PARENT_DIR}/Install-Logs/ || true 
    cd ..
else
    echo -e "${ERROR} Download failed for wayland." 2>&1 | tee -a "$LOG"
fi

clear
