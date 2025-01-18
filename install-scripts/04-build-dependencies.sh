#!/bin/bash
# Install dependencies for building a newer version of hyprland from source

#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# main dependencies #

# packages neeeded
dependencies=(
    # cmake deps
    cmake-extras 
    cmake 
    wget 
    libssl-dev

    # newer gcc
    gcc-14
    g++-14

 
)

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
# Determine the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_build_dependencies.log"

# Installation of build dependencies
printf "\n%s - Installing build dependencies.... \n" "${NOTE}"

for PKG1 in "${dependencies[@]}"; do
  install_package "$PKG1" 2>&1 | tee -a "$LOG"
  if [ $? -ne 0 ]; then
    echo -e "\e[1A\e[K${ERROR} - $PKG1 Package installation failed, Please check the installation logs"
    exit 1
  fi
done

# Install newer version of cmake
CMAKE_VERSION=3.31.4

# check if cmake is already installed manually 
if [ -f "/usr/local/bin/cmake" ]; then
    echo "${NOTE} /usr/local/bin/cmake already exists. Skipping installation of cmake." 2>&1 | tee -a "$LOG"
    exit 0
fi

##
printf "${NOTE} Installing CMake from source...\n"  

# Check if folder exists and remove it
if [ -d "CMake" ]; then
    printf "${NOTE} Removing existing cmake folder...\n"
    rm -rf "CMake"
fi

# Clone and build ImageMagick
printf "${NOTE} Installing cmake...\n"
if git clone --depth 1 --single-branch -b v${CMAKE_VERSION} https://github.com/Kitware/CMake.git; then
    cd CMake || exit 1
    mkdir build && $_ &&
    cmake .. -DCMAKE_INSTALL_PREFIX=/usr/local &&
    make -j `nproc` &&
    if sudo make install 2>&1 | tee -a "$MLOG" ; then
        printf "${OK} CMake installed successfully.\n" 2>&1 | tee -a "$MLOG"
    else
        echo -e "${ERROR} Installation failed for CMake." 2>&1 | tee -a "$MLOG"
    fi
    #moving the addional logs to Install-Logs directory
    mv $MLOG ../Install-Logs/ || true 
    cd ..
else
    echo -e "${ERROR} Download failed for CMake." 2>&1 | tee -a "$LOG"
fi

# Setup gcc-14 for newer language support
echo "Setup gcc-14 compiler..."
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-14 20 --slave /usr/bin/g++ g++ /usr/bin/g++-14
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-13 10 --slave /usr/bin/g++ g++ /usr/bin/g++-13
echo "If you want to change the used gcc version call"
echo "   sudo update-alternatives --config gcc"

clear
