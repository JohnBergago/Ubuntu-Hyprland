#!/bin/bash
# wayland-protocols #

wayland_protocols=(
    build-essential 
    pkg-config 
    meson
    ca-certificates
    libexpat1-dev 
    libffi-dev 
    libxml2-dev
)

#specific branch or release
wayland_protocols_tag="1.39"

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
# Determine the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_wayland_protocols.log"
MLOG="install-$(date +%d-%H%M%S)_wayland_protocols2.log"

# Installation of dependencies
printf "\n%s - Installing wayland-protocols dependencies.... \n" "${NOTE}"

for PKG1 in "${wayland_protocols[@]}"; do
  install_package "$PKG1" 2>&1 | tee -a "$LOG"
  if [ $? -ne 0 ]; then
    echo -e "\e[1A\e[K${ERROR} - $PKG1 Package installation failed, Please check the installation logs"
    exit 1
  fi
done

# Check if wayland-protocols folder exists and remove it
if [ -d "wayland-protocols" ]; then
    printf "${NOTE} Removing existing wayland-protocols folder...\n"
    rm -rf "wayland-protocols"
fi

# Clone and build 
printf "${NOTE} Installing wayland-protocols...\n"
if git clone --recursive -b $wayland_protocols_tag https://gitlab.freedesktop.org/wayland/wayland-protocols.git; then
    cd wayland-protocols || exit 1
        mkdir -p build && cd $_&&
        meson setup --prefix=/usr/local --buildtype=release && 
        ninja &&
    if sudo ninja install 2>&1 | tee -a "$MLOG" ; then
        printf "${OK} wayland-protocols installed successfully.\n" 2>&1 | tee -a "$MLOG"
    else
        echo -e "${ERROR} Installation failed for wayland-protocols." 2>&1 | tee -a "$MLOG"
    fi
    #moving the addional logs to Install-Logs directory
    mv $MLOG ${PARENT_DIR}/Install-Logs/ || true 
    cd ..
else
    echo -e "${ERROR} Download failed for wayland-protocols." 2>&1 | tee -a "$LOG"
fi

clear
