#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# hyprgraphics #

hyprgraphics=(
  libmagic-dev
)

#specific branch or release
hyprgraphics_tag="v0.1.1"

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
# Determine the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_hyprgraphics.log"
MLOG="install-$(date +%d-%H%M%S)_hyprgraphics2.log"

# Installation of dependencies
printf "\n%s - Installing hyprgraphics dependencies.... \n" "${NOTE}"

for PKG1 in "${hyprgraphics[@]}"; do
  install_package "$PKG1" 2>&1 | tee -a "$LOG"
  if [ $? -ne 0 ]; then
    echo -e "\e[1A\e[K${ERROR} - $PKG1 Package installation failed, Please check the installation logs"
    exit 1
  fi
done

# Check if hyprgraphics folder exists and remove it
if [ -d "hyprgraphics" ]; then
    printf "${NOTE} Removing existing hyprgraphics folder...\n"
    rm -rf "hyprgraphics"
fi

# Install libjxl dependencies from tar ball. 
if [ -d "libjxl" ]; then
    printf "${NOTE} Removing existing libjxl folder...\n"
    rm -rf "libjxl"
fi

printf "\n%s - Installing libjxl dependency from tarball.... \n" "${NOTE}"
mkdir -p libjxl && cd $_
wget https://github.com/libjxl/libjxl/releases/download/v0.11.1/jxl-debs-amd64-ubuntu-24.04-v0.11.1.tar.gz
tar -xvf jxl-debs-amd64-ubuntu-24.04-v0.11.1.tar.gz
sudo apt install -y ./libjxl_0.11.1_amd64.deb ./libjxl-dev_0.11.1_amd64.deb
cd ..

# Clone and build 
printf "${NOTE} Installing hyprgraphics...\n"
if git clone --recursive -b $hyprgraphics_tag https://github.com/hyprwm/hyprgraphics.git; then
    cd hyprgraphics || exit 1
		cmake --no-warn-unused-cli -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_INSTALL_PREFIX:PATH=/usr -S . -B ./build
		cmake --build ./build --config Release --target all -j`nproc 2>/dev/null || getconf NPROCESSORS_CONF`
    if sudo cmake --install ./build 2>&1 | tee -a "$MLOG" ; then
        printf "${OK} hyprgraphics installed successfully.\n" 2>&1 | tee -a "$MLOG"
    else
        echo -e "${ERROR} Installation failed for hyprgraphics." 2>&1 | tee -a "$MLOG"
    fi
    #moving the addional logs to Install-Logs directory
    mv $MLOG ${PARENT_DIR}/Install-Logs/ || true 
    cd ..
else
    echo -e "${ERROR} Download failed for hyprgraphics." 2>&1 | tee -a "$LOG"
fi

clear


