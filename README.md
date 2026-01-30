# Layer to support mender-kernel on RaspberryPi

## Usage

Include this repository in your bblayers. It mainly patches u-boot's `boot.scr`
by computing kernelfs partition number from bootfs partition number that is
controlled by mender.

- `bootenv.cmd`: is baked directly to u-boot. Contains addresses and logic to load linux kernel.
- `boot.cmd`: is added to FIT image and contains instructions on booting kernel and constructing FDT
