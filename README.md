# lpc54628 IAP Test Project using the Dual Enhanced Images Feature
* This project demonstrates that booting from a dual enhanced image at 0x40000 and attempting to flash a 2nd dual enhanced image at 0x0 fails with iap status 0x15 which is undocumented.

## Background
* Tested on an OM13094 LPCXpresso54618 dev kit
* A JLINK device is connected to the dev kit's SWD connector

## Ubuntu 18.04 Environment Prerequisites
```bash
sudo apt-get install git build-essential wget exuberant-ctags autoconf m4 libtool autopoint
sudo apt-get remove modemmanager
sudo usermod -a -G dialout $USER
```

## udev rules
```bash
SUBSYSTEM=="usb", ATTR{idVendor}=="1366", MODE="0664", GROUP="plugdev"
SUBSYSTEM=="usb", ATTR{idVendor}=="0403", MODE="0664", GROUP="dialout"
```

## Ubuntu 18.04 - Get the code & build it
```bash
git clone git@github.com:caseykelso/lpc54628.git
cd lpc54628
make bootstrap
make firmware.stock
make firmware.build
```

## Flash NXP's stock IAP project with a Jlink device
```bash
make flash
```

## Flash the modified IAP project with a Jlink device - this project demonstrates an iap result of 0x15 when writing to sector 0x0 using a dual enhanced image at location 0x40000
```bash
make flash.dual
```

## Download flash contents to flash.bin file for inspection
```bash
make flash.download
```

## Serial Debug Output
* Setup udev rules for the dev kit
* Open minicom on /dev/ttyUSB0
* Set flow control to off

## Expected serial debug output for the stock iap flash project
```bash
IAP Flash example

Writing flash sector 1

Erasing flash sector 1

Erasing page 1 in flash sector 1

Flash signature value of page 1

FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF

End of IAP Flash Example
```

## Debug modified iap project

Open terminal 1
```bash
make gdb
```

Open terminal 2
```bash
./gdb-dual.sh
```

## Project Directory Structure
* build.firmware - build directory for modified firmware with dual enhanced image
* downloads - directory with all downloaded 3rd party packages
* downloads/iap_flash - source directory for iap_flash.zip reference project generated by NXP's MCUXpresso SDK Dashboard (SDK_2.5.0_LPC54628J512 iap_flash project)
* downloads/iap_flash/debug - build directory for the reference project
* installed.host - rootfs for any dev tools that need to be built for this project
* source - source code for modified firmware with dual enhanced image, note that this project reference the stock iap_flash project and only modified 3 files, the startup assembly, the linker file, and the CMakeLists.txt. These can be easily diff'd against the stock files in the downloads/iap_flash directory tree


