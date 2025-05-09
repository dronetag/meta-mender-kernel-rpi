FILESEXTRAPATHS:prepend:rpi:= "${THISDIR}/files:"

# offset from first root partition (managed by mender) to first kernel partition (managed by mender-kernel)
# we use this to do correct jump in u-boot script. Original version of mender-kernel does no support u-boot
KERNELFS_OFFSET_TO_ROOTFS = "${@int(d.getVar('MENDER/KERNEL_PART_A_NUMBER')) - int(d.getVar('MENDER_ROOTFS_PART_A_NUMBER'))}"


SRC_URI += "\
    file://bootenv.cmd.in \
    file://boot.cmd.in \
    file://bootcmd.cfg \
"

UBOOT_ENV = "boot"
UBOOT_ENV_SRC_SUFFIX = "cmd"
UBOOT_ENV_SUFFIX = "scr"
BOOT_MEDIA ??= "mmc"

BOOT_CMD_CFG_FILE="${WORKDIR}/_bootcmd.cfg"

UBOOT_EXTRA_CONFIGS="${BOOT_CMD_CFG_FILE}"

# This needs to be in the local.conf file
PREFERRED_PROVIDER_u-boot-default-script = "rpi-u-boot-scr-empty"

do_configure:prepend() {
    BOOTCMD_FILE="${WORKDIR}/bootenv.cmd.inproc"


    sed -e 's/@@KERNELFS_OFFSET_TO_ROOTFS@@/${KERNELFS_OFFSET_TO_ROOTFS}/' \
        -e 's/@@KERNEL_IMAGETYPE@@/${KERNEL_IMAGETYPE}/' \
        -e 's/@@KERNEL_BOOTCMD@@/${KERNEL_BOOTCMD}/' \
        -e 's/@@BOOT_MEDIA@@/${BOOT_MEDIA}/' \
        -e 's|@@KERNEL_EXTRA_ARGS@@|${KERNEL_EXTRA_ARGS}|' \
        "${WORKDIR}/bootenv.cmd.in" > "$BOOTCMD_FILE"

    # Step 1: Remove empty/whitespace-only lines and comment lines (lines starting with #)
    BOOTCMD=$(sed '/^[[:space:]]*$/d' "$BOOTCMD_FILE" | sed '/^\s*#/d' | sed ':a;N;$!ba;s/\n/; /g')

    # Step 2: Escape double quotes
    ESCAPED_BOOTCMD=$(echo "$BOOTCMD" | sed 's/"/\\"/g')

    # Step 3: Write to .cfg fragment
    echo "CONFIG_BOOTCOMMAND=\"${ESCAPED_BOOTCMD}\"" > "${BOOT_CMD_CFG_FILE}"

    sed -e 's/@@KERNELFS_OFFSET_TO_ROOTFS@@/${KERNELFS_OFFSET_TO_ROOTFS}/' \
        -e 's/@@KERNEL_IMAGETYPE@@/${KERNEL_IMAGETYPE}/' \
        -e 's/@@KERNEL_BOOTCMD@@/${KERNEL_BOOTCMD}/' \
        -e 's/@@BOOT_MEDIA@@/${BOOT_MEDIA}/' \
        -e 's|@@KERNEL_EXTRA_ARGS@@|${KERNEL_EXTRA_ARGS}|' \
        "${WORKDIR}/boot.cmd.in" > "${WORKDIR}/${UBOOT_ENV}.${UBOOT_ENV_SRC_SUFFIX}"
}

UBOOT_CONFIG_FRAGMENTS += "${BOOT_CMD_CFG_FILE}"
