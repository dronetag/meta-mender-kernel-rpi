FILESEXTRAPATHS:prepend:rpi:= "${THISDIR}/files:"

# offset from first root partition (managed by mender) to first kernel partition (managed by mender-kernel)
# we use this to do correct jump in u-boot script. Original version of mender-kernel does no support u-boot
KERNELFS_OFFSET_TO_ROOTFS = "${@int(d.getVar('MENDER/KERNEL_PART_A_NUMBER')) - int(d.getVar('MENDER_ROOTFS_PART_A_NUMBER'))}"

do_compile() {
    # I am unable to sed KERNEL_EXTRA_ARGS inside because it contains / hence upon expansion
    # it breaks the sed replace. I tried to replace / with \/ using ${KERNEL_EXTRA_ARGS/\//\\/}
    # but no luck. Hence we bolt it there with echo as env var and then use this var in boot.cmd
    echo "env set kernel_extra_args ${KERNEL_EXTRA_ARGS}" > ${WORKDIR}/boot.cmd
    sed -e 's/@@KERNELFS_OFFSET_TO_ROOTFS@@/${KERNELFS_OFFSET_TO_ROOTFS}/' \
        -e 's/@@KERNEL_IMAGETYPE@@/${KERNEL_IMAGETYPE}/' \
        -e 's/@@KERNEL_BOOTCMD@@/${KERNEL_BOOTCMD}/' \
        -e 's/@@BOOT_MEDIA@@/${BOOT_MEDIA}/' \
        "${WORKDIR}/boot.cmd.in" >> "${WORKDIR}/boot.cmd"
    mkimage -A ${UBOOT_ARCH} -T script -C none -n "Boot script" -d "${WORKDIR}/boot.cmd" boot.scr
}
