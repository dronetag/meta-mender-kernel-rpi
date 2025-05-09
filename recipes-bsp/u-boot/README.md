# U-Boot append

This compiles one part of boot.scr into fwenv and the second is intended to be put inside fitImage.

Maybe we did it wrong but we need no boot.scr to by deployed directly by u-boot-default-script.
Hence it is important to add this to your local.conf / kas.yml

```yaml
PREFERRED_PROVIDER_u-boot-default-script = "rpi-u-boot-scr-empty"
```
