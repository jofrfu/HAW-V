#!/bin/bash
# Author: Mike Wüstenberg
# Date: 26.11.2017
# Version: 0.1
# Description: This Script ist building the Risc-V toolchain.

#Variable
REPO_PATH=riscv-tools/
SKIP_REPO=yes
LINUX=ubuntu
SKIP_TOOLS=yes

echo "building risc-v toolchain"
echo ""

echo "REPO_PATH: $REPO_PATH"
echo "SKIP_REPO: $SKIP_REPO"
echo "LINUX: $LINUX"
echo "SKIP_TOOLS: $SKIP_TOOLS"

echo ""
#Download Git Repo
if [ ! "$SKIP_REPO" = yes ]; then
	#Check for git directory
	echo "init git repo .."
	FILE=$REPO_PATH.git
	if [ ! -f $FILE ]; then
		cd riscv-tools
		git pull origin master
		git submodule update --recursive
	else	#directory empty
		git clone https://github.com/riscv/riscv-tools
		cd riscv-tools
		git submodule update --recursive
	fi
cd ..
else
	echo "init git repo .. SKIPPED"
fi

# install tools
if [ ! "$SKIP_TOOLS" = yes ]; then
	echo "install tools .."
	if [ "$LINUX" = ubuntu ]; then
		sudo apt-get install autoconf automake autotools-dev curl device-tree-compiler libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc
	else
		echo "ERROR: failed to install required tools"
		exit 1
	fi
else
	echo "install tools .. SKIPPED"
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

