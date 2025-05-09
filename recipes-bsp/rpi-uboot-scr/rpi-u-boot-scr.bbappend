FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

# COMPATIBLE = "raspberrypi3 raspberrypi4 raspberrypi4-64"


# Disable this disabled recipe
do_compile() {
    :
}

do_deploy() {
    :
}

# Also mark them as noexec to tell BitBake they do nothing
do_compile[noexec] = "1"
do_deploy[noexec] = "1"
