#!/bin/bash

export BUILD_JOB_NUMBER=$(grep -c ^processor /proc/cpuinfo)
RDIR=$(pwd)

KERNEL_DEFCONFIG=exynos9820-beyondx_defconfig
SOC=9820
BOARD=SRPSC04B011KU
MODEL=beyondx

FUNC_BUILD_KERNEL_GCC() {
    echo " Starting a kernel build using "$KERNEL_DEFCONFIG ""
    export PLATFORM_VERSION=11
    export ANDROID_MAJOR_VERSION=r
    
    make -j$BUILD_JOB_NUMBER ARCH=arm64 \
        CROSS_COMPILE=aarch64-linux-gnu- \
        exynos9820-beyondx_defconfig || exit -1

    make -j$BUILD_JOB_NUMBER ARCH=arm64 \
        CROSS_COMPILE=aarch64-linux-gnu- || exit -1

    mkdtboimg cfg_create build/dtb_9820.img \
        $RDIR/toolchains/configs/exynos9820.cfg \
        -d $RDIR/arch/arm64/boot/dts/exynos
        
    echo " Finished kernel build with gcc"
}

FUNC_BUILD_KERNEL_CLANG() {
    echo " Starting a kernel build using "$KERNEL_DEFCONFIG ""
    export PLATFORM_VERSION=11
    export ANDROID_MAJOR_VERSION=r

make -j$BUILD_JOB_NUMBER ARCH=arm64 \
    CC=clang \
    CFLAGS="-w -Wno-everything -Wno-strict-prototypes -Wno-error" \
    exynos9820-beyondx_defconfig || exit -1

make -j$BUILD_JOB_NUMBER ARCH=arm64 \
    CC=clang \
    CFLAGS="-w -Wno-everything -Wno-strict-prototypes -Wno-error" || exit -1

    mkdtboimg cfg_create build/dtb_9820.img \
        $RDIR/toolchains/configs/exynos9820.cfg \
        -d $RDIR/arch/arm64/boot/dts/exynos
        
    echo " Finished kernel build with clang"
}

FUNC_BUILD_KERNEL_CLANG18() {
    echo " Starting a kernel build using "$KERNEL_DEFCONFIG ""
    export PLATFORM_VERSION=11
    export ANDROID_MAJOR_VERSION=r

make -j$BUILD_JOB_NUMBER ARCH=arm64 \
    CC=$RDIR/toolchains/bin/clang \
    CFLAGS="-w -Wno-everything -Wno-strict-prototypes -Wno-error" \
    exynos9820-beyondx_defconfig || exit -1

make -j$BUILD_JOB_NUMBER ARCH=arm64 \
    CC=$RDIR/toolchains/bin/clang \
    CFLAGS="-w -Wno-everything -Wno-strict-prototypes -Wno-error" || exit -1

    mkdtboimg cfg_create build/dtb_9820.img \
        $RDIR/toolchains/configs/exynos9820.cfg \
        -d $RDIR/arch/arm64/boot/dts/exynos
        
    echo " Finished kernel build with custom clang"
}

FUNC_BUILD_DTBO() {
    mkdtboimg cfg_create build/dtbo_beyondx.img \
        $RDIR/toolchains/configs/beyondx.cfg \
        -d $RDIR/arch/arm64/boot/dts/samsung
}

FUNC_BUILD_RAMDISK() {
    rm -f $RDIR/ramdisk/split_img/boot.img-kernel
    cp $RDIR/arch/arm64/boot/Image $RDIR/ramdisk/split_img/boot.img-kernel
    echo $BOARD > ramdisk/split_img/boot.img-board
    # This is kind of an ugly hack, we could as well touch .placeholder to all of those   it works so why you cry ^-
    mkdir -p $RDIR/ramdisk/ramdisk/debug_ramdisk
    mkdir -p $RDIR/ramdisk/ramdisk/dev
    mkdir -p $RDIR/ramdisk/ramdisk/mnt
    mkdir -p $RDIR/ramdisk/ramdisk/proc
    mkdir -p $RDIR/ramdisk/ramdisk/sys

    rm -rf $RDIR/ramdisk/ramdisk/fstab.exynos9820
    rm -rf $RDIR/ramdisk/ramdisk/fstab.exynos9825

    cp $RDIR/ramdisk/fstab.exynos$SOC $RDIR/ramdisk/ramdisk/

    cd $RDIR/ramdisk/ || exit
    ./repackimg.sh --nosudo
}

FUNC_BUILD_ZIP() {
    cd $RDIR/build || exit
    rm -rf $MODEL-boot-ramdisk.img
    mv $RDIR/ramdisk/image-new.img $RDIR/build/$MODEL-boot-ramdisk.img

    # Make recovery flashable package
    rm -rf $RDIR/build/zip
    mkdir -p $RDIR/build/zip
    cp $RDIR/build/$MODEL-boot-ramdisk.img $RDIR/build/zip/boot.img
    cp $RDIR/build/dtb_$SOC.img $RDIR/build/zip/dtb.img
    cp $RDIR/build/dtbo_beyondx.img $RDIR/build/zip/dtbo.img
    mkdir -p $RDIR/build/zip/META-INF/com/google/android/
    cp $RDIR/toolchains/updater-script $RDIR/build/zip/META-INF/com/google/android/
    cp $RDIR/toolchains/update-binary $RDIR/build/zip/META-INF/com/google/android/
    cd $RDIR/build/zip || exit
    zip -r ../kernel_$MODEL.zip .
    rm -rf $RDIR/build/zip
    cd $RDIR/build || exit
}

# MAIN FUNCTION
rm -rf ./build.log
(
    START_TIME=$(date +%s)

# by uncommenting the function of build you can change the toolchain

#    FUNC_BUILD_KERNEL_GCC
    FUNC_BUILD_KERNEL_CLANG
#    FUNC_BUILD_KERNEL_CLANG18
    FUNC_BUILD_DTBO
    FUNC_BUILD_RAMDISK
    FUNC_BUILD_ZIP

    END_TIME=$(date +%s)

    let "ELAPSED_TIME=$END_TIME-$START_TIME"
    echo "Total compile time was $ELAPSED_TIME seconds"

) 2>&1 | tee -a ./build.log

