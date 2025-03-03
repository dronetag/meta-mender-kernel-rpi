# we use initramfs-framework that places its init script to /init
# most likely to avoid conflicts with /usr and /bin handling

do_compile:append() {
    bbwarn "appending init=/init to default kernel params"
    # if initramfs-framework-base is used, we need to add init=/init to the CMDLINE
    # so the init is actually used instead of searching for default /sbin/init
    if ${@bb.utils.contains('PACKAGE_INSTALL', 'initramfs-framework-base', 'true', 'false', d)}; then
        echo " init=/init" >> "${WORKDIR}/cmdline.txt"
    fi
}
