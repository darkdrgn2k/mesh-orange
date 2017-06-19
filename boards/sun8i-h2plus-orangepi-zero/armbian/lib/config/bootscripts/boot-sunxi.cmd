# DO NOT EDIT THIS FILE
#
# Please edit /boot/armbianEnv.txt to set supported parameters
#

# default values
setenv load_addr "0x44000000"
setenv rootdev "/dev/mmcblk0p1"
setenv verbosity "1"
setenv console "both"
setenv disp_mem_reserves "off"
setenv disp_mode "1920x1080p60"
setenv rootfstype "ext4"

# Print boot source
itest.b *0x28 == 0x00 && echo "U-boot loaded from SD"
itest.b *0x28 == 0x02 && echo "U-boot loaded from eMMC or secondary SD"
itest.b *0x28 == 0x03 && echo "U-boot loaded from SPI"

echo "Boot script loaded from ${devtype}"

if load ${devtype} 0 ${load_addr} /boot/armbianEnv.txt || load ${devtype} 0 ${load_addr} armbianEnv.txt; then
	env import -t ${load_addr} ${filesize}
fi

if test "${console}" = "display" || test "${console}" = "both"; then setenv consoleargs "console=tty1"; fi
if test "${console}" = "serial" || test "${console}" = "both"; then setenv consoleargs "${consoleargs} console=ttyS0,115200"; fi

# get PARTUUID of first partition on SD/eMMC it was loaded from
# mmc 0 is always mapped to device u-boot (2016.09+) was loaded from
if test "${devtype}" = "mmc"; then part uuid mmc 0:1 partuuid; fi

setenv bootargs "root=${rootdev} rootwait rootfstype=${rootfstype} ${consoleargs} cgroup_enable=memory swapaccount=1 hdmi.audio=EDID:0 disp.screen0_output_mode=${disp_mode} panic=10 consoleblank=0 enforcing=0 loglevel=${verbosity} ubootpart=${partuuid} ubootsource=${devtype} ${extraargs} ${extraboardargs}"

if test "${disp_mem_reserves}" = "off"; then setenv bootargs "${bootargs} sunxi_ve_mem_reserve=0 sunxi_g2d_mem_reserve=0 sunxi_fb_mem_reserve=16"; fi

load ${devtype} 0 ${ramdisk_addr_r} /boot/uInitrd || load ${devtype} 0 ${ramdisk_addr_r} uInitrd
load ${devtype} 0 ${kernel_addr_r} /boot/zImage || load ${devtype} 0 ${kernel_addr_r} zImage

load ${devtype} 0 ${fdt_addr_r} /boot/dtb/${fdtfile} || load ${devtype} 0 ${fdt_addr_r} /dtb/${fdtfile}
fdt addr ${fdt_addr_r}
fdt resize 65536
for overlay_file in ${overlays}; do
        if load ${devtype} 0 ${load_addr} boot/dtb/overlay/${overlay_file}.dtbo || load ${devtype} 0 ${load_addr} dtb/overlay/${overlay_file}.dtbo; then
                echo "Applying DT overlay ${overlay_file}.dtbo"
                fdt apply ${load_addr}
        fi
done
bootz ${kernel_addr_r} ${ramdisk_addr_r} ${fdt_addr_r}

# Recompile with:
# mkimage -C none -A arm -T script -d /boot/boot.cmd /boot/boot.scr
