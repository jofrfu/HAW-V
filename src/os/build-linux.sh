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
BUSY_BUILD=yes
CROSS_COMPILER=riscv64-unknown-linux-gnu-
DISK_BUILD=yes
HOST=riscv64-unknown-linux-gnu
RE_BUILD=yes

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
	./configure --prefix=$RISCV CROSS_COMPILE=$CROSS_COMPILER
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

# Build Kernel
if [ $LINUX_BUILD = yes ]; then
	cd $LINUX_VERSION
	make ARCH=riscv defconfig
	make -j$CORE_NUMBER ARCH=riscv CROSS_COMPILE=riscv64-unknown-linux-gnu-
fi

# BusyBox
if [ $BUSY_BUILD = yes ]; then
	cd $TOP
	# Get BusyBox
	rm -r busybox-1.26.2
	curl -L http://busybox.net/downloads/busybox-1.26.2.tar.bz2 > busybox-1.26.2.tar.bz2
	tar xvjf busybox-1.26.2.tar.bz2
	rm busybox-1.26.2.tar.bz2

	cd busybox-1.26.2
	make allnoconfig

	echo "Set Config"
	sed -i 's/# CONFIG_STATIC is not set/CONFIG_STATIC=y/' .config
	sed -i s/'CONFIG_CROSS_COMPILER_PREFIX=""'/CONFIG_CROSS_COMPILER_PREFIX='"'$CROSS_COMPILER'"'/ .config
	sed -i 's/# CONFIG_FEATURE_INSTALLER is not set/CONFIG_FEATURE_INSTALLER=y/' .config
	sed -i 's/# CONFIG_INIT is not set/CONFIG_INIT=y/' .config
	sed -i 's/# CONFIG_ASH is not set/CONFIG_ASH=y/' .config
	sed -i 's/# CONFIG_ASH_JOB_CONTROL is not set/CONFIG_ASH_JOB_CONTROL=n/' .config
	sed -i 's/# CONFIG_MOUNT is not set/CONFIG_MOUNT=y/' .config
	sed -i 's/# CONFIG_FEATURE_USE_INITTAB is not set/CONFIG_FEATURE_USE_INITTAB=y/' .config

	make -j$CORE_NUMBER
else
	echo "Busybox build .. ignored"
	echo
fi

# Root Disk
if [ $DISK_BUILD = yes ]; then
	cd $TOP/$LINUX_VERSION

	mkdir root
	cd root
	mkdir -p bin etc dev lib proc sbin sys tmp usr usr/bin usr/lib usr/sbin

	cp $TOP/busybox-1.26.2/busybox bin

	# Download inittab
	curl -L http://riscv.org/install-guides/linux-inittab > etc/inittab

	#  create a symbolic link to /bin/busybox for init to work.
	ln -s ../bin/busybox sbin/init
	ln -s sbin/init init

	# character device for the console
	sudo mknod dev/console c 5 1

	#  create our initramfs
	find . | cpio --quiet -o -H newc > $TOP/$LINUX_VERSION/rootfs.cpio
fi

if [ $RE_BUILD = yes ]; then
	cp $TOP/.config .config

	# rebuild linux and pk
	cd $TOP/$LINUX_VERSION
	make -j$CORE_NUMBER ARCH=riscv CROSS_COMPILE=$CROSS_COMPILER vmlinux

	cd $TOP/riscv-tools/riscv-pk/build
	rm -rf *

	../configure --prefix=$RISCV CROSS_COMPILE=$CROSS_COMPILER --host=riscv64-unknown-linux-gnu --with-payload=$TOP/$LINUX_VERSION/vmlinux
	make
	make install
fi

