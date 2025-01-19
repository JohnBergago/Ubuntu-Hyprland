#!/bin/bash
# libxcb-errors #

xcb_errors=(
    autoconf
    automake
    xutils-dev
    xcb-proto 
    libtool
)

#specific branch or release
xcb_errors_tag="master"

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
# Determine the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_libxcb_errors.log"
MLOG="install-$(date +%d-%H%M%S)_libxcb_errors2.log"

# Installation of dependencies
printf "\n%s - Installing libxcb-errors dependencies.... \n" "${NOTE}"

for PKG1 in "${xcb_errors[@]}"; do
  re_install_package "$PKG1" 2>&1 | tee -a "$LOG"
  if [ $? -ne 0 ]; then
    echo -e "\e[1A\e[K${ERROR} - $PKG1 Package installation failed, Please check the installation logs"
    exit 1
  fi
done

# Check if libxcb-errors folder exists and remove it
if [ -d "libxcb-errors" ]; then
    printf "${NOTE} Removing existing libxcb-errors folder...\n"
    rm -rf "libxcb-errors"
fi

# Clone and build 
printf "${NOTE} Installing libxcb-errors...\n"
if git clone --recursive -b $xcb_errors_tag https://gitlab.freedesktop.org/xorg/lib/libxcb-errors.git; then
    cd libxcb-errors || exit 1
        # As the autogen.sh uses autoreconf, which tries to initialize the installation dir for libtoolize where 
        # it finds install-sh or install.sh first (from srcdir, srcdir/.. or srcdir/../..), we need to add a fix
        # location to the configure input. Because our main setup script is called install.sh in the parent dir. 
        mkdir build-aux
        # Check if AC_CONFIG_AUX_DIR already exists
        if grep -q AC_CONFIG_AUX_DIR configure.ac; then
            echo "AC_CONFIG_AUX_DIR already exists."
        else
        # Find the line containing AC_CONFIG_MACRO_DIR
        ac_macro_line=$(grep -n AC_CONFIG_MACRO_DIR configure.ac)

            if [[ -z "$ac_macro_line" ]]; then
                echo "AC_MACRO_DIR not found in configure.ac. Appending AC_CONFIG_AUX_DIR to the end."
                echo "AC_CONFIG_AUX_DIR(build-aux)" >> configure.ac
            else
                # Extract the line number
                line_number=$(echo "$ac_macro_line" | cut -d: -f1)

                # Use sed to insert the line after AC_MACRO_DIR
                sed -i "${line_number}a AC_CONFIG_AUX_DIR(build-aux)" configure.ac
                echo "AC_CONFIG_AUX_DIR inserted after AC_MACRO_DIR."
            fi
        fi
        ./autogen.sh
        ./configure 
        make 
    if sudo make install 2>&1 | tee -a "$MLOG" ; then
        printf "${OK} libxcb-errors installed successfully.\n" 2>&1 | tee -a "$MLOG"
    else
        echo -e "${ERROR} Installation failed for libxcb-errors." 2>&1 | tee -a "$MLOG"
    fi
    # moving the addional logs to Install-Logs directory
    mv $MLOG ${PARENT_DIR}/Install-Logs/ || true 
    cd ..
else
    echo -e "${ERROR} Download failed for libxcb-errors." 2>&1 | tee -a "$LOG"
fi

clear
