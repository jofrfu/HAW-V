#!/bin/bash
# Author: Mike Wüstenberg
# Date: 26.11.2017
# Version: 0.8
# Description: This Script ist building a Risc-V Linux.

#Variable
### Toolchain Options ###
TOOLCHAIN_SETUP=no # Toolchain setup. options[full, no]
LINUX=ubuntu # Set Host Linux Type. options[ubuntu, fedora]

### linux options ###
LOAD_REPO=yes # 
MAKEFILE=yes # Create Linux make file. options[yes, no]
LINUX_VERSION=linux-4.14 # Set Linux Version to install. options[linux-4.14]
LINUX_SETUP=yes # Download linux repository und kernel. options[yes, no]
LINUX_BUILD=yes # Make linux. option[yes, no
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
        -s|--setup)
        TOOLCHAIN_SETUP=full
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
		-b|--busybox)
        BUSY_BUILD=no
        shift # past argument=value
        ;;
		-f|--filesystem)
        DISK_BUILD=no
        shift # past argument=value
        ;;
		-re|--rebuild)
        RE_BUILD=no
        shift # past argument=value
        ;;
        -h|--help)
        echo "Usage: build-linux.sh [OPTION]..."
        echo "Download and build of the risc-v linux. Superuser rights required for initramfs creation"
        echo
        echo "-l=, --linux=                 set Linux distribution for tool installation"
        echo "-s,  --setup                  skip toolchain download and installation"
		echo "-m,  --make-makefile          disable the generation of the makefile"
		echo "-ls, --linux-setup            skip download of the linux repository"
		echo "-lb, --linux-build            disbale the compile of the kernel"
		echo "-b,  --busybox                disable busybox istallation"
		echo "-f,  --fileysystem            disable initramfs creation"
		echo "-re, --rebuild                disable linux and pk rebuild"
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
echo "Toolchain setup:            $TOOLCHAIN_SETUP"
echo "Linux Host:                 $LINUX"
echo "Create Linux makefile:      $MAKEFILE"
echo "Linux version:              $LINUX_VERSION"
echo "Download Linux repository:  $LINUX_SETUP"
echo "Make linux:                 $LINUX_BUILD"
echo "Cross Compile:              $CROSS_COMPILER"
echo "Compile core number:        $CORE_NUMBER"
echo "Download and bluid busybox: $BUSY_BUILD"
echo "Create initramfs:           $DISK_BUILD"
echo "Rebuild Linux and PK:       $RE_BUILD"
echo "Host for linux rebuild:     $HOST"
echo

# Download and install full toolchain
if [ $TOOLCHAIN_SETUP = full ]; then
	./build-toolchain.sh --linux=$LINUX
fi

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

# Option to add exports to the shell configuration
# TODO ~/.bashrc

# Create Linux makefiles
if [ $MAKEFILE = yes ]; then
	# Set workdirectory 
	cd $TOP/riscv-tools/riscv-gnu-toolchain 
	
	# Configure makefile creation, Set the CROSS_COMPILE
	./configure --prefix=$RISCV CROSS_COMPILE=$CROSS_COMPILER
	make linux
	echo "Generate linux makefile .. complett"
else
	echo "Genearate linux makefile .. ignored"
fi

cd $TOP
# Riscv linux download and linux kernel
if [ $LINUX_SETUP = yes ]; then
	echo "Setup linux .."
	if [ $LINUX_VERSION = linux-3.14.33 ]; then # does not work
		git clone https://github.com/riscv/riscv-linux.git $LINUX_VERSION

		curl -L https://www.kernel.org/pub/linux/kernel/v3.x/linux-3.14.33.tar.xz | tar -xJkf -
	elif [ $LINUX_VERSION = linux-4.14 ]; then
		git clone -b riscv-linux-4.14 https://github.com/riscv/riscv-linux.git linux-4.14

		curl -L https://www.kernel.org/pub/linux/kernel/v4.x/linux-4.14.tar.xz | tar -xJkf -
	else
		echo "ERROR: Wrong Linux Version"
		exit 1
	fi
	echo
else
	echo "Setup linux .. ingored"
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

# BusyBox
if [ $BUSY_BUILD = yes ]; then
	echo "Busybox build .."
	cd $TOP
	# Get BusyBox
	curl -L http://busybox.net/downloads/busybox-1.26.2.tar.bz2 > busybox-1.26.2.tar.bz2
	tar xvjf busybox-1.26.2.tar.bz2
	rm busybox-1.26.2.tar.bz2

	cd busybox-1.26.2
	# make BusyBox config with all options not set
	make allnoconfig

	# search busybox config and set options
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
fi

# Root Disk
if [ $DISK_BUILD = yes ]; then
	echo "Create initramfs .."
	cd $TOP/$LINUX_VERSION

	# make linux directory
	mkdir root
	cd root
	mkdir -p bin etc dev lib proc sbin sys tmp usr usr/bin usr/lib usr/sbin

	cp $TOP/busybox-1.26.2/busybox bin

	# Create inittab for startup
	cd etc
	echo "::sysinit:/bin/busybox mount -t proc proc /proc" >> inittab
	echo "::sysinit:/bin/busybox mount -t tmpfs tmpfs /tmp" >> inittab
	echo "::sysinit:/bin/busybox mount -o remount,rw /dev/htifblk0 /" >> inittab
	echo "::sysinit:/bin/busybox --install -s" >> inittab
	echo "/dev/console::sysinit:-/bin/ash" >> inittab
	cd ..

	#  create a symbolic link to /bin/busybox for init to work.
	ln -s ../bin/busybox sbin/init
	ln -s sbin/init init

	# character device for the console
	sudo mknod dev/console c 5 1

	#  create our initramfs
	find . | cpio --quiet -o -H newc > $TOP/$LINUX_VERSION/rootfs.cpio
else 
	echo "Create initramfs .. ignored"
fi

if [ $RE_BUILD = yes ]; then
	# rebuild linux and pk
	cd $TOP/$LINUX_VERSION

	echo "Rebuild Linux .."
	
	# Config initramfs use
	sed -i 's/# CONFIG_INITRAMFS_SOURCE is not set/CONFIG_INITRAMFS_SOURCE="rootfs.cpio"/' .config
	
	make -j$CORE_NUMBER ARCH=riscv CROSS_COMPILE=$CROSS_COMPILER vmlinux

	echo "Rebuild PK"
	cd $TOP/riscv-tools/riscv-pk/build
	rm -rf *
	../configure --prefix=$RISCV --host=$HOST --with-payload=$TOP/$LINUX_VERSION/vmlinux
	make
	make install
else 
	echo "Rebuild Linux .. ignored"
fi
