#!/bin/bash
# Author: Mike Wüstenberg
# Date: 26.11.2017
# Version: 0.1
# Description: This Script ist building the Risc-V toolchain.

#Variable
REPO_PATH=riscv-tools/
REPO_NAME=/riscv-tools/
LOAD_REPO=yes
LINUX=ubuntu
TOOL_INSTALL=yes

# Argument parse
for i in "$@"
do
case $i in
	-R=*|--repository-path=*)
	REPO_PATH="${i#*=}"
	REPO_PATH+=$REPO_NAME
	shift # past argument=value
	;;
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
	-h|--help)
	echo "Usage: build-toolchain [OPTION]..."
	echo "Download and build of the risc-v toolchain. Superuser rights required for tool installation"
	echo
	echo "-R=, --repository-path=       repository download path"
	echo "-r,  --repository-load        disable repository download"
	echo "-t,  --tool-install           disable tool installation"
	echo "-l=, --linux=                 set Linux distribution for tool installation"
	echo "-h , --help                   help"
	exit 0
	;;
	*)
          # unknown option
    	;; 
esac
done

echo "building risc-v toolchain"
echo ""
echo "REPO_PATH:    $REPO_PATH"
echo "LOAD_REPO:    $LOAD_REPO"
echo "LINUX:        $LINUX"
echo "TOOL_INSTALL: $TOOL_INSTALL"
echo ""

# install tools
if [ "$TOOL_INSTALL" = yes ]; then
	echo "install tools .."
	if [ "$LINUX" = ubuntu ]; then
		sudo apt-get install autoconf automake autotools-dev curl device-tree-compiler libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc
	elif [ "$LINUX" = fedora ]; then
		sudo dnf install autoconf automake @development-tools curl dtc libmpc-devel mpfr-devel gmp-devel gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib-devel
	else
		echo "ERROR: failed to install required tools"
		exit 1
	fi
else
	echo "install tools .. ignored"
fi

#Download Git Repo
if [ "$LOAD_REPO" = yes ]; then
	#Check for git directory
	echo "init git repo .."
	FILE=$REPO_PATH.git
	if [ ! -f $FILE ]; then
		cd $REPO_PATH
		git pull origin master
		git submodule update --recursive
	else	#directory empty
		git clone https://github.com/riscv/riscv-tools
		cd $REPO_PATH
		git submodule update --recursive
	fi
cd ..
else
	echo "init git repo .. ignored"
fi

#Exports
export TOP=$(pwd)
export RISCV=$TOP/riscv
export PATH=$PATH:$RISCV/bin

cd $TOP/riscv-tools
./build.sh

#Testing the toolchain
cd $RISCV
echo -e '#include <stdio.h>\n int main(void) { printf("Hello world!\\n"); return 0; }' > hello.c
riscv64-unknown-elf-gcc -o hello hello.c