#!/bin/sh
downloads/gcc-arm-none-eabi-7-2017-q4-major/bin/arm-none-eabi-gdb -s downloads/iap_flash_debug/iap_flash.elf -ex "target remote localhost:2331"


