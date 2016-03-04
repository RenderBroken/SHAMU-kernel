#!/bin/bash

#
#  Build Script for Render Kernel for SHAMU!
#  Based off AK'sbuild script - Thanks!
#

# Bash Color
green='\033[01;32m'
red='\033[01;31m'
blink_red='\033[05;31m'
restore='\033[0m'

clear

# Resources
THREAD="-j9"
KERNEL="zImage-dtb"
DEFCONFIG="render_defconfig"

# Kernel Details
VER=Render-Kernel
VARIANT="N6-MM"

# Vars
export LOCALVERSION=~`echo $VER`
export ARCH=arm
export SUBARCH=arm
export KBUILD_BUILD_USER=RenderBroken
export KBUILD_BUILD_HOST=RenderServer.net
export CCACHE=ccache

# Paths
KERNEL_DIR=`pwd`
REPACK_DIR="${HOME}/android/source/kernel/SHAMU-AnyKernel"
PATCH_DIR="${HOME}/android/source/kernel/SHAMU-AnyKernel/patch"
MODULES_DIR="${HOME}/android/source/kernel/SHAMU-AnyKernel/modules"
ZIP_MOVE="${HOME}/android/source/zips/shamu-zips"
ZIMAGE_DIR="${HOME}/android/source/kernel/SHAMU-kernel/arch/arm/boot"

# Functions
function checkout_branches {
		cd $REPACK_DIR
		git checkout rk-mm-anykernel
		cd $KERNEL_DIR
}

function clean_all {
		cd $REPACK_DIR
		rm -rf $MODULES_DIR/*
		rm -rf $KERNEL
		rm -rf zImage
		cd $KERNEL_DIR
		echo
		make clean && make mrproper
}

function make_kernel {
		echo
		make $DEFCONFIG
		make $THREAD
		cp -vr $ZIMAGE_DIR/$KERNEL $REPACK_DIR/zImage
}

function make_modules {
		rm `echo $MODULES_DIR"/*"`
		find $KERNEL_DIR -name '*.ko' -exec cp -v {} $MODULES_DIR \;
}

function make_zip {
		cd $REPACK_DIR
		zip -r9 RenderKernel-"$VARIANT"-R.zip *
		mv RenderKernel-"$VARIANT"-R.zip $ZIP_MOVE
		cd $KERNEL_DIR
}


DATE_START=$(date +"%s")

echo -e "${green}"
echo "Render Kernel Creation Script:"
echo -e "${restore}"

echo "Pick Toolchain..."
select choice in HYPER-arm-eabi-4.9 UBER-4.9-Cortex-a15 UBER-5.3-cortex-a15
do
case "$choice" in
	"HYPER-arm-eabi-4.9")
		export CROSS_COMPILE=${HOME}/android/source/toolchains/HYPER-arm-eabi-4.9-01112016/bin/arm-eabi-
		break;;
	"UBER-4.9-Cortex-a15")
		export CROSS_COMPILE=${HOME}/android/source/toolchains/UBER-arm-eabi-4.9-cortex-a15-08062015/bin/arm-eabi-
		break;;
	"UBER-5.2")
		export CROSS_COMPILE=${HOME}/android/source/toolchains/UBER-arm-eabi-5.2-12042015/bin/arm-eabi-
		break;;
esac
done

while read -p "Do you want to clean stuffs (y/n)? " cchoice
do
case "$cchoice" in
	y|Y )
		checkout_branches
		clean_all
		echo
		echo "All Cleaned now."
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Invalid try again!"
		echo
		;;
esac
done

echo

while read -p "Do you want to build kernel (y/n)? " dchoice
do
case "$dchoice" in
	y|Y)
		checkout_branches
		make_kernel
		make_modules
		make_zip
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Invalid try again!"
		echo
		;;
esac
done

echo -e "${green}"
echo "-------------------"
echo "Build Completed in:"
echo "-------------------"
echo -e "${restore}"

DATE_END=$(date +"%s")
DIFF=$(($DATE_END - $DATE_START))
echo "Time: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
echo
