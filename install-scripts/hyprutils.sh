#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# hyprutils #

hyprutils=(

)

#specific branch or release
hyprutils_tag="v0.3.3"

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
# Determine the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_hyprutils.log"
MLOG="install-$(date +%d-%H%M%S)_hyprutils2.log"

# Installation of dependencies
printf "\n%s - Installing hyprutils dependencies.... \n" "${NOTE}"

for PKG1 in "${hyprutils[@]}"; do
  install_package "$PKG1" 2>&1 | tee -a "$LOG"
  if [ $? -ne 0 ]; then
    echo -e "\e[1A\e[K${ERROR} - $PKG1 Package installation failed, Please check the installation logs"
    exit 1
  fi
done

# Check if hyprutils folder exists and remove it
if [ -d "hyprutils" ]; then
    printf "${NOTE} Removing existing hyprutils folder...\n"
    rm -rf "hyprutils"
fi

# Clone and build 
printf "${NOTE} Installing hyprutils...\n"
if git clone --recursive -b $hyprutils_tag https://github.com/hyprwm/hyprutils.git; then
    cd hyprutils || exit 1
		cmake --no-warn-unused-cli -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_INSTALL_PREFIX:PATH=/usr/local -S . -B ./build
		cmake --build ./build --config Release --target all -j`nproc 2>/dev/null || getconf NPROCESSORS_CONF`
    if sudo cmake --install ./build 2>&1 | tee -a "$MLOG" ; then
        printf "${OK} hyprutils installed successfully.\n" 2>&1 | tee -a "$MLOG"
    else
        echo -e "${ERROR} Installation failed for hyprutils." 2>&1 | tee -a "$MLOG"
    fi
    #moving the addional logs to Install-Logs directory
    mv $MLOG ../Install-Logs/ || true 
    cd ..
else
    echo -e "${ERROR} Download failed for hyprutils." 2>&1 | tee -a "$LOG"
fi

clear


