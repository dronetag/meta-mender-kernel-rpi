FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
LICENSE = "CLOSED"

COMPATIBLE = "raspberrypi3 raspberrypi4 raspberrypi4-64"

PROVIDES += "u-boot-default-script"

# Really - just do nothing - bno boot.scr must appear in the IMAGE_ROOT
# because we compile everything in the u-boot environment instead
do_compile[noexec] = "1"
