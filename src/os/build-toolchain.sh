#!/bin/bash
# Author: Mike Wüstenberg
# Date: 26.11.2017
# Version: 0.1
# Description: This Script ist building the Risc-V toolchain.

#Variable
LOAD_REPO=yes
LINUX=ubuntu
TOOL_INSTALL=yes
SETUP=yes
TEST_NAME=toolchaintest

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
	-h|--help)
	echo "Usage: build-toolchain.sh [OPTION]..."
	echo "Download and build of the risc-v toolchain. Superuser rights required for tool installation"
	echo
	echo "-r,  --repository-load        disable repository download"
	echo "-t,  --tool-install           disable tool installation"
	echo "-l=, --linux=                 set Linux distribution for tool installation"
	echo "-s,  --setup                  skip repository download and tool installation"
	echo "-h, --help                    help"
	exit 0
	;;
	*)
          # unknown option
    	;;
esac
done

echo
echo "build risc-v toolchain"
echo
echo "SETUP:     $SETUP"
echo



if [ "$SETUP" = yes ]; then
	./setup-riscv-repository.sh -r=$LOAD_REPO -t=$TOOL_INSTALL -l=$LINUX
else
	echo "install tools .. ignored"
	echo "init git repo .. ignored"
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

cd $TOP/riscv-tools
./build.sh

#Testing the toolchain
DIR=$RISCV/$TEST_NAME
if [ ! -d $DIR ]; then
	mkdir $FILE
fi
cd $DIR

echo -e '#include <stdio.h>\n int main(void) { printf("Your Toolchain ist working!\\n"); return 0; }' > $TEST_NAME.c
$RISCV/bin/riscv64-unknown-elf-gcc -o $TEST_NAME $TEST_NAME.c

echo
$RISCV/bin/spike pk $TEST_NAME
echo
