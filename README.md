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

## Debug it

Open terminal 1
```bash
make gdb
```

Open terminal 2
```bash
./gdb.sh
```


