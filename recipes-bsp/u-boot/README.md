# U-Boot append

This compiles one part of boot.scr into fwenv and the second is intended to be put inside fitImage.

Maybe we did it wrong but we need no boot.scr to by deployed directly by u-boot-default-script.
Hence it is important to add this to your local.conf / kas.yml

```yaml
PREFERRED_PROVIDER_u-boot-default-script = "rpi-u-boot-scr-empty"
```

## Files and logic

- `bootenv.cmd`: is baked directly to u-boot. Contains addresses and logic to load linux kernel.
- `boot.cmd`: is added to FIT image and contains instructions on booting kernel and constructing FDT

fitImage is an archive of u-boot scripts, DeviceTree overlays and Linux kernel(s). Hence it requires
some logic that will assemble everything together and launch Linux kernel with right arguments.