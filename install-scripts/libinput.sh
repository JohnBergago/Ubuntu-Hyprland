#!/bin/bash
# libinput #

libinput=(
    check 
    libudev-dev 
    libevdev-dev 
    libwacom-dev 
    libgtk-3-dev
    libglib2.0-dev 
    libmtdev-dev
)

#specific branch or release
libinput_tag="1.27.1"

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
# Determine the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_libinput.log"
MLOG="install-$(date +%d-%H%M%S)_libinput2.log"

# Installation of dependencies
printf "\n%s - Installing libinput dependencies.... \n" "${NOTE}"

for PKG1 in "${libinput[@]}"; do
  install_package "$PKG1" 2>&1 | tee -a "$LOG"
  if [ $? -ne 0 ]; then
    echo -e "\e[1A\e[K${ERROR} - $PKG1 Package installation failed, Please check the installation logs"
    exit 1
  fi
done

# Check if libinput folder exists and remove it
if [ -d "libinput" ]; then
    printf "${NOTE} Removing existing libinput folder...\n"
    rm -rf "libinput"
fi

# Clone and build 
printf "${NOTE} Installing libinput...\n"
if git clone --recursive -b $libinput_tag https://gitlab.freedesktop.org/libinput/libinput.git; then
    cd libinput || exit 1
        mkdir -p build && cd $_ && 
        meson setup ..            \
            --prefix /usr/local   \
            --buildtype=release   \
            -Ddocumentation=false &&
        ninja 
    if sudo ninja install 2>&1 | tee -a "$MLOG" ; then
        echo Success >> $MLOG
        printf "${OK} libinput installed successfully.\n" 2>&1 | tee -a "$MLOG"
    else
        echo -e "${ERROR} Installation failed for libinput." 2>&1 | tee -a "$MLOG"
    fi
    #moving the addional logs to Install-Logs directory
    mv $MLOG ../Install-Logs/ || true 
    cd ..
else
    echo -e "${ERROR} Download failed for libinput." 2>&1 | tee -a "$LOG"
fi

# clear
