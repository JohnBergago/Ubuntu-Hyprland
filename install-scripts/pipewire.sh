#!/bin/bash
# pipewire #

pipewire=(
    findutils
    git
    libapparmor-dev
    libasound2-dev
    libavcodec-dev
    libavfilter-dev
    libavformat-dev
    libdbus-1-dev
    libbluetooth-dev
    libglib2.0-dev
    libgstreamer1.0-dev
    libgstreamer-plugins-base1.0-dev
    libsbc-dev
    libsdl2-dev
    libsnapd-glib-dev
    libudev-dev
    libva-dev
    libv4l-dev
    libx11-dev
    meson
    ninja-build
    pkg-config
    python3-docutils
    systemd
)

#specific branch or release
pipewire_tag="1.2.7"

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
# Determine the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_pipewire.log"
MLOG="install-$(date +%d-%H%M%S)_pipewire2.log"

# Installation of dependencies
printf "\n%s - Installing pipewire dependencies.... \n" "${NOTE}"

for PKG1 in "${pipewire[@]}"; do
  install_package "$PKG1" 2>&1 | tee -a "$LOG"
  if [ $? -ne 0 ]; then
    echo -e "\e[1A\e[K${ERROR} - $PKG1 Package installation failed, Please check the installation logs"
    exit 1
  fi
done

# Check if pipewire folder exists and remove it
if [ -d "pipewire" ]; then
    printf "${NOTE} Removing existing pipewire folder...\n"
    rm -rf "pipewire"
fi

# Clone and build 
printf "${NOTE} Installing pipewire...\n"
if git clone --recursive -b $pipewire_tag https://gitlab.freedesktop.org/pipewire/pipewire.git; then
    cd pipewire || exit 1
        
        meson setup builddir
        meson configure builddir -Dprefix=/usr/local 
        meson compile -C builddir  
    if sudo meson install -C builddir 2>&1 | tee -a "$MLOG" ; then
        printf "${OK} pipewire installed successfully.\n" 2>&1 | tee -a "$MLOG"
    else
        echo -e "${ERROR} Installation failed for pipewire." 2>&1 | tee -a "$MLOG"
    fi
    #moving the addional logs to Install-Logs directory
    mv $MLOG ${PARENT_DIR}/Install-Logs/ || true 
    cd ..
else
    echo -e "${ERROR} Download failed for pipewire." 2>&1 | tee -a "$LOG"
fi

clear
