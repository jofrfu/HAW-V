#!/bin/bash
# Author: Mike Wüstenberg
# Date: 26.11.2017
# Version: 0.8
# Description: This Script is building a risc-v Linux.

#Variable
### Tool-chain Options ###
TOOLCHAIN_SETUP=no # Tool-chain setup. options[full, no]
LINUX=ubuntu # Set Host Linux Type. options[ubuntu, fedora]

### linux options ###
LOAD_REPO=yes #
MAKEFILE=yes # Create Linux make file. options[yes, no]
LINUX_VERSION=linux-4.14.13 # Set Linux Version to install. options[linux-4.14, linux-4.14.13]
LINUX_SETUP=yes # Download linux repository and kernel. options[yes, no]
LINUX_BUILD=yes # Make linux. option[yes, no]
CROSS_COMPILER=riscv64-unknown-linux-gnu- # Coss Compiler for make operations. options[riscv64-unknown-linux-gnu-]
CORE_NUMBER=4 # Set core number for compile operations. options[int > 0]

### BusyBox ###
BUSY_BUILD=yes # Download and bluid busybox version 1.26.2. options[yes, no]
DISK_BUILD=yes # Create initramfs. options[yes, no]
HOST=riscv64-unknown-linux-gnu # Set Host for linux rebuild. options[riscv64-unknown-linux-gnu]
RE_BUILD=yes # Rebuild Linux and PK with initramfs. options[yes, no]

# Argument parse
for i in "$@"
do
case $i in
        -l=*|--linux=*)
        LINUX="${i#*=}"
        shift # past argument=value
        ;;
        -m|--make-makefile)
        MAKEFILE=no
        shift # past argument=value
        ;;
        -ls|--linux-setup)
        LINUX_SETUP=no
        shift # past argument=value
        ;;
        -lb|--linux-build)
        LINUX_BUILD=no
        shift # past argument=value
        ;;
        -h|--help)
        echo "Usage: build-linux.sh [OPTION]..."
        echo "Download and build of the risc-v linux. Superuser rights required for initramfs creation"
        echo
        echo "-l=, --linux=                 set Linux distribution for tool installation"
        echo "-s,  --setup                  skip tool-chain download and installation"
        echo "-m,  --make-makefile          disable the generation of the makefile"
        echo "-ls, --linux-setup            skip download of the linux repository"
        echo "-lb, --linux-build            disable the compile of the kernel"
        echo "-h,  --help                   help"
        exit 0
        ;;
        *)
        echo "unknown option"
        ;;
esac
done

echo
echo "build risc-v linux"
echo
echo "Linux Host:                 $LINUX"
echo "Create Linux makefile:      $MAKEFILE"
echo "Linux version:              $LINUX_VERSION"
echo "Download Linux repository:  $LINUX_SETUP"
echo "Make linux:                 $LINUX_BUILD"
echo "Cross Compile:              $CROSS_COMPILER"
echo "Compile core number:        $CORE_NUMBER"
echo

# Exports
export TOP=$(pwd)
export RISCV=$TOP/riscv
export PATH=$PATH:$RISCV/bin

echo
echo "exports"
echo "TOP:   $TOP"
echo "RISCV: $RISCV"
echo "PATH:  $PATH"
echo
# Create Linux makefiles
if [ $MAKEFILE = yes ]; then
        # Set workdirectory
        cd $TOP/riscv-tools/riscv-gnu-toolchain

        # Configure makefile creation, Set the CROSS_COMPILE
        ./configure --prefix=$RISCV CROSS_COMPILE=$CROSS_COMPILER
        cd build
        make linux
        cd
        echo "Generate linux makefile .. complete"
else
        echo "Generate linux makefile .. ignored"
fi

cd $TOP
# Riscv linux and kernel download 
if [ $LINUX_SETUP = yes ]; then
        echo "Setup linux .."
        if [ $LINUX_VERSION = linux-4.14.13 ]; then
                git clone https://github.com/riscv/riscv-linux.git $LINUX_VERSION

                curl -L https://www.kernel.org/pub/linux/kernel/v4.x/linux-4.14.13.tar.xz | tar -xJkf -

 #              $LINUX_VERSION/scripts/patchkernel $TOP/$LINUX_VERSION
        elif [ $LINUX_VERSION = linux-4.14 ]; then
                git clone -b riscv-linux-4.14 https://github.com/riscv/riscv-linux.git linux-4.14

                curl -L https://www.kernel.org/pub/linux/kernel/v4.x/linux-4.14.tar.xz | tar -xJkf -
        else
                echo "ERROR: Wrong Linux Version"
                exit 1
        fi
        echo
else
        echo "Setup linux .. ignored"
fi

# Build Kernel
if [ $LINUX_BUILD = yes ]; then
        echo "Build kernel .."
        cd $LINUX_VERSION
        # Create default config
        make ARCH=riscv defconfig
        # make linux, set Cross Compile
        make -j$CORE_NUMBER ARCH=riscv CROSS_COMPILE=$CROSS_COMPILER

if [ $MAKEFILE = yes ]; then
        # Set workdirectory
        cd $TOP/riscv-tools/riscv-gnu-toolchain

        # Configure makefile creation, Set the CROSS_COMPILE
        ./configure --prefix=$RISCV CROSS_COMPILE=$CROSS_COMPILER
        cd build
        make linux
        cd
        echo "Generate linux makefile .. complete"
else
        echo "Generate linux makefile .. ignored"
fi

cd $TOP
# Riscv linux download and linux kernel
if [ $LINUX_SETUP = yes ]; then
        echo "Setup linux .."
        if [ $LINUX_VERSION = linux-4.14.13 ]; then # does not work
                git clone https://github.com/riscv/riscv-linux.git $LINUX_VERSION

                curl -L https://www.kernel.org/pub/linux/kernel/v4.x/linux-4.14.13.tar.xz | tar -xJkf -

#               $LINUX_VERSION/scripts/patchkernel $TOP/$LINUX_VERSION
        elif [ $LINUX_VERSION = linux-4.14 ]; then
                git clone -b riscv-linux-4.14 https://github.com/riscv/riscv-linux.git linux-4.14

                curl -L https://www.kernel.org/pub/linux/kernel/v4.x/linux-4.14.tar.xz | tar -xJkf -
        else
                echo "ERROR: Wrong Linux Version"
                exit 1
        fi
        echo
else
        echo "Setup linux .. ignored"
fi

# Build Kernel
if [ $LINUX_BUILD = yes ]; then
        echo "Build kernel .."
        cd $LINUX_VERSION
        # Create default config
        make ARCH=riscv defconfig
        # make linux, set Cross Compile
        make -j$CORE_NUMBER ARCH=riscv CROSS_COMPILE=$CROSS_COMPILER
else
        echo "Build kernel .. ignored"
fi
