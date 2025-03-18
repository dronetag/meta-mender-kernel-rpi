require recipes-kernel/linux/mender-kernel-linux-yocto.inc

SRC_URI += " \
    ${@bb.utils.contains("KERNEL_IMAGETYPE", "fitImage", "file://initramfs-image-bundle.cfg", "", d)} \
"

# If a DTB is included in fitImage then we should? specify
# the address where it should be loaded. In sync with u-boot.
UBOOT_DTB_LOADADDRESS = "0x02600000"

# Addresses used during fitImage assembly that secure where
# the ramdisk should be loaded. This should be in sync what
# u-boot expects.
UBOOT_RD_LOADADDRESS = "0x02700000"
UBOOT_RD_ENTRYPOINT = "0x02700000"
