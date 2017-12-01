#!/bin/bash
# Author: Mike Wüstenberg
# Date: 26.11.2017
# Version: 0.1
# Description: This Script ist building the Risc-V toolchain.

#Variable
REPO_PATH=riscv-tools/
LOAD_REPO=yes
TOOL_INSTALL=yes
LINUX=ubuntu

# Argument parse
for i in "$@"
do
case $i in
        -r=*|--repository-load=*)
        LOAD_REPO="${i#*=}"
        shift # past argument=value
        ;;
        -t=*|--tool-install=*)
        TOOL_INSTALL="${i#*=}"
        shift # past argument=value
        ;;
        -l=*|--linux=*)
        LINUX="${i#*=}"
        shift # past argument=value
        ;;
        -h|--help)
        echo "Usage: setuo-riscv-repositroy.sh [OPTION]..."
        echo "Download and build of the risc-v toolchain. Superuser rights required for tool installation"
        echo
        echo "-r=, --repository-load=       disable repository download"
        echo "-t=, --tool-install=          disable tool installation"
        echo "-l=, --linux=                 set Linux distribution for tool installation"
        echo "-h , --help                   help"
        exit 0
        ;;
        *)
          # unknown option
        ;;
esac
done

echo
echo "setup risc-v toolchain"
echo
echo "REPO_PATH:    $REPO_PATH"
echo "LOAD_REPO:    $LOAD_REPO"
echo "LINUX:        $LINUX"
echo "TOOL_INSTALL: $TOOL_INSTALL"
echo

# install tools
if [ "$TOOL_INSTALL" = yes ]; then
        echo "install tools .."
        if [ "$LINUX" = ubuntu ]; then
                sudo sudo apt-get install autoconf automake autotools-dev curl device-tree-compiler libmpc-dev libmpfr-dev libgmp-dev libusb-1.0-0-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev device-tree-compiler pkg-config git
        elif [ "$LINUX" = fedora ]; then
                 sudo dnf install autoconf automake @development-tools curl dtc libmpc-devel mpfr-devel gmp-devel gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib-devel git
else
                echo "ERROR: failed to install required tools"
                exit 1
        fi
else
        echo "install tools .. ignored"
fi

#Download Git Repo
if [ "$LOAD_REPO" = yes ]; then
        echo "init git repo .."
        FILE=$REPO_PATH.git
        if [ -s $FILE ]; then
                echo "Update Repo"
                cd $REPO_PATH
                git pull origin master
                git submodule update --init --recursive
        else
                echo "Clone Repo"
                git clone https://github.com/riscv/riscv-tools
                cd $REPO_PATH
                git submodule update --init --recursive
        fi
cd ..
else
        echo "init git repo .. ignored"
fi
echo
