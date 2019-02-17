# lpc54628 - hello world

## Ubuntu 18.04 - Get the code & build it
```bash
git clone git@github.com:caseykelso/lpc54628.git
cd lpc54628
make bootstrap
make firmware
```

## Flash it with a Jlink device
```bash
make flash
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

## Debug it

Open terminal 1
```bash
make gdb
```

Open terminal 2
```bash
./gdb.sh
```


