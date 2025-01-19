#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# sdbus_cpp #

sdbus_cpp=(
    libsystemd-dev
    expat
)

#specific branch or release
sdbus_cpp_tag="v2.1.0"

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
# Determine the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_sdbus_cpp.log"
MLOG="install-$(date +%d-%H%M%S)_sdbus_cpp2.log"

# Installation of dependencies
printf "\n%s - Installing sdbus_cpp dependencies.... \n" "${NOTE}"

for PKG1 in "${sdbus_cpp[@]}"; do
  install_package "$PKG1" 2>&1 | tee -a "$LOG"
  if [ $? -ne 0 ]; then
    echo -e "\e[1A\e[K${ERROR} - $PKG1 Package installation failed, Please check the installation logs"
    exit 1
  fi
done

# Check if sdbus_cpp folder exists and remove it
if [ -d "sdbus-cpp" ]; then
    printf "${NOTE} Removing existing sdbus_cpp folder...\n"
    rm -rf "sdbus-cpp"
fi

# Clone and build 
printf "${NOTE} Installing sdbus_cpp...\n"
if git clone --recursive -b $sdbus_cpp_tag https://github.com/Kistler-Group/sdbus-cpp.git; then
    cd sdbus-cpp || exit 1
    mkdir -p build && cd $_
    cmake .. -DCMAKE_BUILD_TYPE=Release -DSDBUSCPP_BUILD_DOCS=OFF -DSDBUSCPP_BUILD_TESTS=OFF -DCMAKE_INSTALL_PREFIX:PATH=/usr/local
    if sudo cmake --build . --target install 2>&1 | tee -a "$MLOG" ; then
        printf "${OK} sdbus_cpp installed successfully.\n" 2>&1 | tee -a "$MLOG"
    else
        echo -e "${ERROR} Installation failed for sdbus_cpp." 2>&1 | tee -a "$MLOG"
    fi
    #moving the addional logs to Install-Logs directory
    mv $MLOG ${PARENT_DIR}/Install-Logs/ || true 
    cd ..
else
    echo -e "${ERROR} Download failed for sdbus_cpp." 2>&1 | tee -a "$LOG"
fi




