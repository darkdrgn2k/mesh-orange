Linux Kernel Downloader
=======================

This sub-directory is responsible for downloading the matching compiled
linux kernel file bundles for this project.

These releases can be found at:
    https://github.com/hamishcoleman/linux/releases

It is intended to contain a generic multi-platform linux kernel with some
patches to support the single-board-computers that the rest of the build
system support.  Not all boards use this kernel, but when it is simple to
add support, or when specific patches are needed, this kernel will be used.


Build from Source notes:
------------------------

It is intended for this to eventually become automated, but for the moment,
it is simply documented here:

Kernel Source:
    git clone git@github.com:hamishcoleman/linux.git
    git checkout mvp

Default Config:
    make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- mvp-armhf_defconfig

Update with new Config (if needed):
    make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- nconfig

Build:
    make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- -j2 zImage LOADADDR=0x42000000 dtbs modules

Install into build dir:
    LINUX=$PWD/linux
    BUILD=$PWD/build/linux-armhf

    cd $LINUX
    rm -rf $BUILD
    mkdir -p $BUILD/dtb
    cp arch/arm/boot/dts/sun8i-h2-plus-orangepi-zero.dtb $BUILD/dtb
    cp arch/arm/boot/dts/sun7i-a20-bananapi.dtb $BUILD/dtb
    cp arch/arm/boot/dts/sun4i-a10-cubieboard.dtb $BUILD/dtb
    cp arch/arm/boot/zImage $BUILD/
    cp .config $BUILD/
    make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- \
        INSTALL_MOD_PATH=$BUILD/ modules_install
    rm -f $BUILD/lib/modules/*/build
    rm -f $BUILD/lib/modules/*/source

Bundle:
    tar -C build -cJf build/linux-armhf.tar.xz linux-armhf


---
Kernel features TODO:

bananapi:
    cpufreq not working
    USB OTG not working
    usb ports not working
    sata untested, but detected
    video out / audio out - untested, not needed in a router build

cubieboard:
    cpufreq not working
    USB OTG not working
    NAND not detected
    sata untested, but detected
    video out / audio in/out - untested, not needed in a router build

orange-pi-zero:
    second and third usb port - device tree needs updating to enable
    video out / audio out - untested, not needed in a router build

general:
    Trial workqueue.power_efficient and possibly enable this by default
    using WQ_POWER_EFFICIENT_DEFAULT

