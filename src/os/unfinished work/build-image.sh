#!/bin/bash
# Author: Mike Wüstenberg
# Date: 26.11.2017
# Version: 0.8
# Description: 

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
        BUSY_BUILD=no)
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
echo "Linux Host:                 $LINUX"
echo "Linux version:              $LINUX_VERSION"
echo "Cross Compile:              $CROSS_COMPILER"
echo "Compile core number:        $CORE_NUMBER"
echo "Download and build busybox: $BUSY_BUILD"
echo "Create initramfs:           $DISK_BUILD"
echo "Rebuild Linux and PK:       $RE_BUILD"
echo "Host for linux rebuild:     $HOST"
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


# BusyBox
if [ $BUSY_BUILD = yes ]; then
	echo "Busybox build .."
	cd $TOP

	cd busybox-1.26.2
	# make BusyBox config with all options not set
#	rm .config
	make allnoconfig
	sleep 1

	# search busybox config and set options
	echo "Set Config"
	sed -i -e's/# CONFIG_STATIC is not set/CONFIG_STATIC=y/g' \
	-e 's/CONFIG_CROSS_COMPILER_PREFIX=""/CONFIG_CROSS_COMPILER_PREFIX="riscv64-unknown-linux-gnu-"/g' \
	-e 's/# CONFIG_FEATURE_INSTALLER is not set/CONFIG_FEATURE_INSTALLER=y/g' \
	-e 's/# CONFIG_INIT is not set/CONFIG_INIT=y/g' \
	-e 's/# CONFIG_ASH is not set/CONFIG_ASH=y/g' \
	-e 's/# CONFIG_ASH_JOB_CONTROL is not set/CONFIG_ASH_JOB_CONTROL=n/g' \
	-e 's/# CONFIG_MOUNT is not set/CONFIG_MOUNT=y/g' \
	-e 's/# CONFIG_FEATURE_USE_INITTAB is not set/CONFIG_FEATURE_USE_INITTAB=y/g' \
	-e 's/# CONFIG_BASENAME is not set/CONFIG_BASENAME=y/g' \
	-e 's/# CONFIG_UNAME is not set/CONFIG_UNAME=y/g' \
	-e 's/CONFIG_UNAME_OSNAME=""/CONFIG_UNAME_OSNAME="Riscv-64"/g' \
	-e 's/# CONFIG_LS is not set/CONFIG_LS=y/g' .config

#	make -j$CORE_NUMBER
else
	echo "Busybox build .. ignored"
fi

# Root Disk
if [ $DISK_BUILD = yes ]; then
	echo "Create initramfs .."
	cd $TOP/$LINUX_VERSION

	sudo rm -r -f root
	sudo rm root.bin
	sudo dd if=/dev/zero of=root.bin bs=1M count=64

	sudo mkfs.ext2 -F root.bin

	mkdir mnt
	sudo mount -o loop root.bin mnt

	# make linux directory
	cd mnt
	sudo mkdir -p bin etc dev lib proc sbin sys tmp usr usr/bin usr/lib usr/sbin

	cp $TOP/busybox-1.26.2/busybox bin/busybox


	# character device for the console
#	sudo mknod dev/console c 5 1

	# Create inittab for startup
	cd etc
	sudo echo "::sysinit:/bin/busybox mount -t proc proc /proc" >> inittab
	sudo echo "::sysinit:/bin/busybox mount -t tmpfs tmpfs /tmp" >> inittab
	sudo echo "::sysinit:/bin/busybox mount -o remount,rw /dev/htifblk0 /" >> inittab
	sudo echo "::sysinit:/bin/busybox --install -s" >> inittab
 	sudo echo "/dev/console::sysinit:-/bin/ash" >> inittab
	cd ..

	#  create a symbolic link to /bin/busybox for init to work.
	ln -s ../bin/busybox sbin/init
#	ln -s sbin/init init

	#  create our initramfs
#	find . | cpio --quiet -o -H newc > $TOP/$LINUX_VERSION/rootfs.cpio

	cd ..
	sudo umount mnt
else
	echo "Create initramfs .. ignored"
fi

if [ $RE_BUILD = no ]; then
	# rebuild linux and pk
	cd $TOP/$LINUX_VERSION

	echo "Rebuild Linux .."

#	make ARCH=riscv defconfig
#	sleep 1


	# Config initramfs use
#	sed -i '/# CONFIG_RELAY is not set/a\ CONFIG_INITRAMFS_COMPRESSION=".gz"/' .config
#	sed -i '/# CONFIG_RELAY is not set/a\ CONFIG_RD_LZ4=y/' .config
#	sed -i '/# CONFIG_RELAY is not set/a\ CONFIG_RD_LZO=y/' .config
#	sed -i '/# CONFIG_RELAY is not set/a\ CONFIG_RD_XZ=y/' .config
#	sed -i '/# CONFIG_RELAY is not set/a\ CONFIG_RD_LZMA=y/' .config
#	sed -i '/# CONFIG_RELAY is not set/a\ CONFIG_RD_BZIP2=y/' .config
#	sed -i '/# CONFIG_RELAY is not set/a\ CONFIG_RD_GZIP=y/' .config
#	sed -i '/# CONFIG_RELAY is not set/a\ CONFIG_INITRAMFS_ROOT_GID=0/' .config
#	sed -i '/# CONFIG_RELAY is not set/a\ CONFIG_INITRAMFS_ROOT_UID=0/' .config
#	sed -i '/# CONFIG_RELAY is not set/a\ CONFIG_INITRAMFS_SOURCE="rootfs.cp"/' .config
#	sed -i '/# CONFIG_RELAY is not set/a\ CONFIG_BLK_DEV_INITRD=y/' .config

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
