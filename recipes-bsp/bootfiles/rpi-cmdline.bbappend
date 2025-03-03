# we use initramfs-framework that places its init script to /init
# most likely to avoid conflicts with /usr and /bin handling
CMDLINE:append = " init=/init "