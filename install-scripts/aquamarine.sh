#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# aquamarine #

aquamarine=(

)

#specific branch or release
aquamarine_tag="v0.7.1"

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
# Determine the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_aquamarine.log"
MLOG="install-$(date +%d-%H%M%S)_aquamarine2.log"

# Installation of dependencies
printf "\n%s - Installing aquamarine dependencies.... \n" "${NOTE}"

for PKG1 in "${aquamarine[@]}"; do
  install_package "$PKG1" 2>&1 | tee -a "$LOG"
  if [ $? -ne 0 ]; then
    echo -e "\e[1A\e[K${ERROR} - $PKG1 Package installation failed, Please check the installation logs"
    exit 1
  fi
done

# Check if aquamarine folder exists and remove it
if [ -d "aquamarine" ]; then
    printf "${NOTE} Removing existing aquamarine folder...\n"
    rm -rf "aquamarine"
fi

# Clone and build 
printf "${NOTE} Installing aquamarine...\n"
if git clone --recursive -b $aquamarine_tag https://github.com/hyprwm/aquamarine.git; then
    cd aquamarine || exit 1
		cmake --no-warn-unused-cli -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_INSTALL_PREFIX:PATH=/usr/local -S . -B ./build 
        cmake --build ./build --config Release --target all -j`nproc 2>/dev/null || getconf _NPROCESSORS_CONF` 
    if sudo cmake --install ./build 2>&1 | tee -a "$MLOG" ; then
        printf "${OK} aquamarine installed successfully.\n" 2>&1 | tee -a "$MLOG"
    else
        echo -e "${ERROR} Installation failed for aquamarine." 2>&1 | tee -a "$MLOG"
    fi
    #moving the addional logs to Install-Logs directory
    mv $MLOG ../Install-Logs/ || true 
    cd ..
else
    echo -e "${ERROR} Download failed for aquamarine." 2>&1 | tee -a "$LOG"
fi

clear


