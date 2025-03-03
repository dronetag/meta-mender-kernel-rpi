# Layer to support mender-kernel on RaspberryPi

## Usage

Include this repository in your bblayers. It mainly patches u-boot's `boot.scr`
by computing kernelfs partition number from bootfs partition number that is
controlled by mender.
