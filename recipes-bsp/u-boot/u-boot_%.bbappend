FILESEXTRAPATHS:prepend:rpi:= "${THISDIR}/files:"

# offset from first root partition (managed by mender) to first kernel partition (managed by mender-kernel)
# we use this to do correct jump in u-boot script. Original version of mender-kernel does no support u-boot
KERNELFS_OFFSET_TO_ROOTFS = "${@int(d.getVar('MENDER/KERNEL_PART_A_NUMBER')) - int(d.getVar('MENDER_ROOTFS_PART_A_NUMBER'))}"


SRC_URI += "\
    file://bootenv.cmd.in \
    file://boot.cmd.in \
    file://bootcmd.cfg \
    file://_bootcmd.cfg \
"

UBOOT_ENV = "boot"
UBOOT_ENV_SRC_SUFFIX = "cmd"
UBOOT_ENV_SUFFIX = "scr"
BOOT_MEDIA ??= "mmc"

BOOT_CMD_CFG_FILE="${WORKDIR}/_bootcmd.cfg"

UBOOT_EXTRA_CONFIGS="${BOOT_CMD_CFG_FILE}"

# This needs to be in the local.conf file
PREFERRED_PROVIDER_u-boot-default-script = "rpi-u-boot-scr-empty"

KERNEL_EXTRA_BOOT_ARGS ??= ""
UBOOT_BOOT_CONFIGURATION ??= ""

do_patch:append() {
    generate_bootenv_file(d)
    generate_bootcmd_file(d)
}

def generate_bootenv_file(d):
    from pathlib import Path
    workdir = d.getVar("WORKDIR")
    bootenv_template = Path(workdir, "bootenv.cmd.in").read_text()
    bootenv_bootcmd = (bootenv_template
        .replace("@@KERNELFS_OFFSET_TO_ROOTFS@@", d.getVar("KERNELFS_OFFSET_TO_ROOTFS"))
        .replace("@@KERNEL_IMAGETYPE@@", d.getVar("KERNEL_IMAGETYPE"))
        .replace("@@KERNEL_BOOTCMD@@", d.getVar("KERNEL_BOOTCMD"))
        .replace("@@BOOT_MEDIA@@", d.getVar("BOOT_MEDIA"))
        .replace("@@KERNEL_EXTRA_BOOT_ARGS@@", d.getVar("KERNEL_EXTRA_BOOT_ARGS"))
        .replace("@@UBOOT_BOOT_CONFIGURATION@@", d.getVar("UBOOT_BOOT_CONFIGURATION"))
    )
    # Step 1: Remove empty/whitespace-only lines and comment lines (lines starting with #)
    bootenv_bootcmd = "; ".join(line for line in bootenv_bootcmd.splitlines() if line.strip() and not line.startswith("#"))
    # Step 2: Escape double quotes
    bootenv_bootcmd = bootenv_bootcmd.replace('"', '\\"')
    # Step 3: Write to .cfg fragment
    boot_cmd_cfg_file = d.getVar("BOOT_CMD_CFG_FILE")
    with open(boot_cmd_cfg_file, "wt") as f:
        f.write(f"CONFIG_BOOTCOMMAND=\"{bootenv_bootcmd}\"\n")


def generate_bootcmd_file(d):
    from pathlib import Path
    workdir = d.getVar("WORKDIR")
    bootfile_template = Path(d.getVar("WORKDIR"), "boot.cmd.in").read_text()
    bootfile_content = (bootfile_template
        .replace("@@KERNELFS_OFFSET_TO_ROOTFS@@", d.getVar("KERNELFS_OFFSET_TO_ROOTFS"))
        .replace("@@KERNEL_IMAGETYPE@@", d.getVar("KERNEL_IMAGETYPE"))
        .replace("@@KERNEL_BOOTCMD@@", d.getVar("KERNEL_BOOTCMD"))
        .replace("@@BOOT_MEDIA@@", d.getVar("BOOT_MEDIA"))
        .replace("@@KERNEL_EXTRA_BOOT_ARGS@@", d.getVar("KERNEL_EXTRA_BOOT_ARGS"))
        .replace("@@UBOOT_BOOT_CONFIGURATION@@", d.getVar("UBOOT_BOOT_CONFIGURATION"))
    )
    uboot_env = d.getVar("UBOOT_ENV")
    uboot_env_src_suffix = d.getVar("UBOOT_ENV_SRC_SUFFIX")
    with open(f"{workdir}/{uboot_env}.{uboot_env_src_suffix}", "wt") as f:
        f.write(bootfile_content)


#
# Legacy do-configure
#
# do_configure:prepend() {
#     BOOTCMD_FILE="${WORKDIR}/bootenv.cmd.inproc"
#
#     sed -e 's/@@KERNELFS_OFFSET_TO_ROOTFS@@/${KERNELFS_OFFSET_TO_ROOTFS}/' \
#         -e 's/@@KERNEL_IMAGETYPE@@/${KERNEL_IMAGETYPE}/' \
#         -e 's/@@KERNEL_BOOTCMD@@/${KERNEL_BOOTCMD}/' \
#         -e 's/@@BOOT_MEDIA@@/${BOOT_MEDIA}/' \
#         -e 's|@@KERNEL_EXTRA_ARGS@@|${KERNEL_EXTRA_ARGS}|' \
#         "${WORKDIR}/bootenv.cmd.in" > "$BOOTCMD_FILE"
#
#     BOOTCMD=$(sed '/^[[:space:]]*$/d' "$BOOTCMD_FILE" | sed '/^\s*#/d' | sed ':a;N;$!ba;s/\n/; /g')
#
#     # Step 2: Escape double quotes
#     ESCAPED_BOOTCMD=$(echo "$BOOTCMD" | sed 's/"/\\"/g')
#
#     # Step 3: Write to .cfg fragment
#     echo "CONFIG_BOOTCOMMAND=\"${ESCAPED_BOOTCMD}\"" > "${BOOT_CMD_CFG_FILE}"
#
#     sed -e 's/@@KERNELFS_OFFSET_TO_ROOTFS@@/${KERNELFS_OFFSET_TO_ROOTFS}/' \
#         -e 's/@@KERNEL_IMAGETYPE@@/${KERNEL_IMAGETYPE}/' \
#         -e 's/@@KERNEL_BOOTCMD@@/${KERNEL_BOOTCMD}/' \
#         -e 's/@@BOOT_MEDIA@@/${BOOT_MEDIA}/' \
#         -e 's|@@KERNEL_EXTRA_BOOT_ARGS@@|${KERNEL_EXTRA_BOOT_ARGS}|' \
#         -e 's|@@UBOOT_BOOT_CONFIGURATION@@|${UBOOT_BOOT_CONFIGURATION}|' \
#         "${WORKDIR}/boot.cmd.in" > "${WORKDIR}/${UBOOT_ENV}.${UBOOT_ENV_SRC_SUFFIX}"
# }


UBOOT_CONFIG_FRAGMENTS += "${BOOT_CMD_CFG_FILE}"
