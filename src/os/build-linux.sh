#!/bin/bash
# Author: Mike Wüstenberg
# Date: 26.11.2017
# Version: 0.1
# Description: This Script ist building a Risc-V Linux.

#Variable
LOAD_REPO=yes
LINUX=ubuntu
TOOL_INSTALL=yes
SETUP=full
MAKEFILE=yes
LINUX_VERSION=linux-4.14
LINUX_SETUP=yes
LINUX_BUILD=yes
CORE_NUMBER=4

# Argument parse
for i in "$@"
do
case $i in
        -r|--repository-load)
        LOAD_REPO=no
        shift # past argument=value
        ;;
        -t|--tool-install)
        TOOL_INSTALL=no
        shift # past argument=value
        ;;
        -l=*|--linux=*)
        LINUX="${i#*=}"
        shift # past argument=value
        ;;
        -s|--setup)
        SETUP=no
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
        echo "Usage: build-toolchain.sh [OPTION]..."
        echo "Download and build of the risc-v toolchain. Superuser rights required for tool installation"
        echo
        echo "-r,  --repository-load        disable repository download"
        echo "-t,  --tool-install           disable tool installation"
        echo "-l=, --linux=                 set Linux distribution for tool installation"
        echo "-s,  --setup                  skip repository download and tool installation"
	echo "-m,  --make-makefile          disable the generation of the makefile"
	echo "-ls, --linux-setup            skip download of the linux repository"
	echo "-lb, --linux-build            disbale the building of the kernel"
        echo "-h,  --help                   help"
        exit 0
        ;;
        *)
          # unknown option
        ;;
esac
done

echo
echo "build risc-v linux"
echo
echo "SETUP:         $SETUP"
echo "MAKEFILE:      $MAKEFILE"
echo "LINUX_VERSION: $LINUX_VERSION"
echo "LINUX_SETUP:   $LINUX_SETUP"
echo

#Setup
if [ $SETUP = full ]; then
	./build-toolchain.sh
fi

#Exports
export TOP=$(pwd)
export RISCV=$TOP/riscv
export PATH=$PATH:$RISCV/bin

echo
echo "exports"
echo "TOP:   $TOP"
echo "RISCV: $RISCV"
echo "PATH:  $PATH"
echo

# Makefile
if [ $MAKEFILE = yes ]; then
	echo "Generate makefile .."

	cd $TOP/riscv-tools/riscv-gnu-toolchain
	./configure --prefix=$RISCV CROSS_COMPILE=riscv64-unknown-linux-gnu-
	make linux
	echo
else
	echo "Genearate makefile .. ignored"
	echo
fi
cd $TOP
# Linux Setup
if [ $LINUX_SETUP = yes ]; then
	echo "Setup linux .."


	if [ $LINUX_VERSION = linux-3.14.33 ]; then # ´does not work
		git clone https://github.com/riscv/riscv-linux.git $LINUX_VERSION

		curl -L https://www.kernel.org/pub/linux/kernel/v3.x/linux-3.14.33.tar.xz | tar -xJkf -
	elif [ $LINUX_VERSION = linux-4.14 ]; then
		git clone https://github.com/riscv/riscv-linux.git linux-4.14

		curl -L https://www.kernel.org/pub/linux/kernel/v4.x/linux-4.14.tar.xz | tar -xJkf -
	else
		echo "ERROR: Wrong Linux Version"
		exit 1
	fi
	echo
else
	echo "Setup linux .. ingored"
	echo
fi

#Build Kernel
if [ $LINUX_BUILD = yes ]; then
	cd $LINUX_VERSION
	make ARCH=riscv defconfig
	make -j$CORE_NUMBER ARCH=riscv CROSS_COMPILE=riscv64-unknown-linux-gnu-
fi
