HASH := $(shell git rev-parse --short=10 HEAD)
OS := $(shell uname)
ARCH := $(shell uname -m)
J=8
BASE.DIR=$(PWD)
DOWNLOADS.DIR=$(BASE.DIR)/downloads
INSTALLED.HOST.DIR=$(BASE.DIR)/installed.host
INSTALLED.TARGET.DIR=$(BASE.DIR)/installed.target
SDK.IAP.ARCHIVE=iap_flash-lpc54628J512-sdk2.5.0.zip
SDK.IAP.URL=https://s3.amazonaws.com/ckelso-toolchain/$(SDK.IAP.ARCHIVE)
SDK.IAP.DIR=$(DOWNLOADS.DIR)/iap_flash
SDK.IAP.BUILD=$(BASE.DIR)/build.firmware
SDK.IAP.TOOLCHAINFILE=$(SDK.IAP.DIR)/armgcc.cmake
TOOLCHAIN.NAME=gcc-arm-none-eabi-7-2017-q4-major
TOOLCHAIN.ARCHIVE.LINUX=$(DOWNLOADS.DIR)/$(TOOLCHAIN.NAME)-linux.tar.bz2
TOOLCHAIN.ARCHIVE.OSX=$(DOWNLOADS.DIR)/$(TOOLCHAIN.NAME)-mac.tar.bz2
TOOLCHAIN.DIR=$(BASE.DIR)/$(TOOLCHAIN.NAME)
TOOLCHAIN.URL.LINUX=https://s3.amazonaws.com/buildroot-sources/$(TOOLCHAIN.NAME)-linux.tar.bz2
TOOLCHAIN.URL.OSX=https://s3.amazonaws.com/buildroot-sources/$(TOOLCHAIN.NAME)-mac.tar.bz2
CMAKE.URL=https://s3.amazonaws.com/buildroot-sources/cmake-3.10.2.tar.gz
CMAKE.DIR=$(DOWNLOADS.DIR)/cmake-3.10.2
CMAKE.ARCHIVE=$(DOWNLOADS.DIR)/cmake-3.10.2.tar.gz
CMAKE.BIN=$(INSTALLED.HOST.DIR)/bin/cmake
JLINK.ARCHIVE=JLink_Linux_V634h_x86_64.tgz
JLINK.URL=https://s3.amazonaws.com/ckelso-toolchain/$(JLINK.ARCHIVE)
#JLINK.URL=https://www.segger.com/downloads/jlink/JLink_Linux_V634h_x86_64.tgz
JLINK.DIR=$(DOWNLOADS.DIR)/JLink_Linux_V634h_x86_64
JLINK.FLASH.BIN=$(JLINK.DIR)/JLinkExe
JLINK.GDB.BIN=$(JLINK.DIR)/JLinkGDBServer
JLINK.SHA.FLASH.SCRIPT.DEBUG=$(BASE.DIR)/flash.sha.jlink.debug
JLINK.FLASH.SLOT1.SCRIPT.DEBUG=$(BASE.DIR)/flash.slot1.jlink.debug
JLINK.FLASH.SLOT2.SCRIPT.DEBUG=$(BASE.DIR)/flash.slot2.jlink.debug
JLINK.FLASH.SCRIPT.RELEASE=$(BASE.DIR)/flash.jlink.release
JLINK.FLASH.BL.SCRIPT=$(BASE.DIR)/flash.bl.jlink
JLINK.FLASH.DOWNLOAD.SCRIPT=$(BASE.DIR)/flash.download
JLINK.RESET.SCRIPT=$(BASE.DIR)/reset.jlink
JLINK.ERASE.SCRIPT=$(BASE.DIR)/erase.jlink
JLINK.DOWNLOAD.SCRIPT=$(BASE.DIR)/download.jlink
JLINK.UPLOAD.SCRIPT=$(BASE.DIR)/upload.jlink
JLINK.OSX.ARCHIVE=JLink_MacOSX_V634c.pkg
JLINK.OSX.URL=https://s3.amazonaws.com/ckelso-toolchain/$(JLINK.OSX.ARCHIVE)
JLINK.OSX.DIR=$(DOWNLOADS.DIR)/JLink.pkg/Applications/SEGGER/JLink_V634c
JLINK.OSX.FLASH.BIN=$(JLINK.OSX.DIR)/JLinkExe
JLINK.OSX.GDB.BIN=$(JLINK.OSX.DIR)/JLinkGDBServer
FIRMWARE.SLOT1.RELEASE.BIN=$(FIRMWARE.SLOT1.BUILD)/Release/firmware-slot1.bin
FIRMWARE.SLOT1.DEBUG.BIN=$(FIRMWARE.SLOT1.BUILD)/Debug/firmware-slot1.bin
FIRMWARE.SLOT1.DEBUG.SREC=$(FIRMWARE.SLOT1.BUILD)/Debug/firmware-slot1.srec
FIRMWARE.SLOT1.DEBUG.SREC.FILLED=$(FIRMWARE.SLOT1.BUILD)/Debug/firmware-slot1.srec.filled
FIRMWARE.SLOT1.RELEASE.ELF=$(FIRMWARE.SLOT1.BUILD)/Release/firmware-slot1.elf
FIRMWARE.SLOT1.DEBUG.ELF=$(FIRMWARE.SLOT1.BUILD)/Debug/firmware-slot1.elf
FIRMWARE.SLOT2.RELEASE.BIN=$(FIRMWARE.SLOT2.BUILD)/Release/firmware-slot2.bin
FIRMWARE.SLOT2.DEBUG.BIN=$(FIRMWARE.SLOT2.BUILD)/Debug/firmware-slot2.bin
FIRMWARE.SLOT2.DEBUG.SREC=$(FIRMWARE.SLOT2.BUILD)/Debug/firmware-slot2.srec
FIRMWARE.SLOT2.DEBUG.SREC.FILLED=$(FIRMWARE.SLOT2.BUILD)/Debug/firmware-slot2.srec.filled
FIRMWARE.SLOT2.RELEASE.ELF=$(FIRMWARE.SLOT2.BUILD)/Release/firmware-slot2.elf
FIRMWARE.SLOT2.DEBUG.ELF=$(FIRMWARE.SLOT2.BUILD)/Debug/firmware-slot2.elf
FIRMWARE.SLOT1.UPDATE=$(BASE.DIR)/update_slot1.sh
FIRMWARE.SLOT2.UPDATE=$(BASE.DIR)/update_slot2.sh
FIRMWARE.DIR=$(BASE.DIR)/firmware
FIRMWARE.SLOT1.BUILD=$(BASE.DIR)/build.firmware-slot1
FIRMWARE.SLOT2.BUILD=$(BASE.DIR)/build.firmware-slot2

bootstrap: toolchain cmake jlink.fetch

ctags: .FORCE
	cd $(BASE.DIR) && ctags -R --exclude=.git --exclude=installed.host --exclude=installed.target --exclude=downloads  --exclude=build.* --exclude=$(TOOLCHAIN.NAME) .

jlink.fetch: .FORCE
ifeq ($(OS), Linux)
	mkdir -p $(DOWNLOADS.DIR) && cd $(DOWNLOADS.DIR) && rm -rf $(JLINK.ARCHIVE) && wget -q $(JLINK.URL) && tar xf $(JLINK.ARCHIVE)
endif

ifeq ($(OS), Darwin)
	mkdir -p $(DOWNLOADS.DIR) && cd $(DOWNLOADS.DIR) && rm -rf $(JLINK.OSX.ARCHIVE) && wget -q $(JLINK.OSX.URL) && xar -xf $(JLINK.OSX.ARCHIVE) && cd JLink.pkg && cat Payload | gunzip -dc |cpio -i
endif

flash.download: .FORCE
ifeq ($(OS), Linux)
	$(JLINK.FLASH.BIN) -device LPC54628J512 -if SWD -speed 4000 -autoconnect 1 -CommanderScript $(JLINK.FLASH.DOWNLOAD.SCRIPT)
endif

ifeq ($(OS), Darwin)
	$(JLINK.OSX.FLASH.BIN) -device LPC54628J512 -if SWD -speed 4000 -autoconnect 1 -CommanderScript $(JLINK.FLASH.DOWNLOAD.SCRIPT)
endif

gdb: .FORCE
ifeq ($(OS), Linux)
	$(JLINK.GDB.BIN) -device LPC54628J512 -if SWD -speed 4000 -autoconnect 1
endif

ifeq ($(OS), Darwin)
	$(JLINK.OSX.GDB.BIN) -device LPC54628J512 -if SWD -speed 4000 -autoconnect 1
endif

reset: .FORCE
ifeq ($(OS), Linux)
	$(JLINK.FLASH.BIN) -device LPC54628J512 -if SWD -speed 4000 -autoconnect 1 -CommanderScript $(JLINK.RESET.SCRIPT)
endif

ifeq ($(OS), Darwin)
	$(JLINK.OSX.FLASH.BIN) -device LPC54628J512 -if SWD -speed 4000 -autoconnect 1 -CommanderScript $(JLINK.RESET.SCRIPT)
endif

toolchain: .FORCE
ifeq ($(OS), Linux)
	mkdir -p $(DOWNLOADS.DIR) && cd $(DOWNLOADS.DIR) && wget -q $(TOOLCHAIN.URL.LINUX)
	tar xf $(TOOLCHAIN.ARCHIVE.LINUX)
endif

ifeq ($(OS), Darwin)
	mkdir -p $(DOWNLOADS.DIR) && cd $(DOWNLOADS.DIR) && wget -q $(TOOLCHAIN.URL.OSX)
	tar xf $(TOOLCHAIN.ARCHIVE.OSX)
endif
toolchain.clean: .FORCE
	rm -rf $(TOOLCHAIN.ARCHIVE.LINUX)
	rm -rf $(TOOLCHAIN.ARCHIVE.OSX)
	rm -rf $(TOOLCHAIN.DIR)


cmake.fetch: .FORCE
	cd $(DOWNLOADS.DIR) && wget -q $(CMAKE.URL) && tar xf $(CMAKE.ARCHIVE)

cmake: cmake.fetch
	cd $(CMAKE.DIR) && ./configure --prefix=$(INSTALLED.HOST.DIR) --no-system-zlib && make -j$(J) && make install

cmake.clean: .FORCE
	rm -rf $(CMAKE.DIR)

firmware: firmware.clean firmware.build

firmware.clean: .FORCE
	rm -rf $(SDK.IAP.BUILD)

firmware.build: .FORCE
	mkdir -p $(SDK.IAP.BUILD)
	cd $(SDK.IAP.BUILD) && $(CMAKE.BIN) -DCMAKE_TOOLCHAIN_FILE=$(SDK.IAP.TOOLCHAINFILE) -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=debug $(SDK.IAP.DIR)

sdk: sdk.clean sdk.fetch

sdk.clean: .FORCE
	rm -rf $(SDK.IAP.DIR)
	rm -f $(DOWNLOADS.DIR)/$(SDK.IAP.ARCHIVE)

sdk.fetch: .FORCE
	mkdir -p $(DOWNLOADS.DIR)
	cd $(DOWNLOADS.DIR) && wget $(SDK.IAP.URL) && unzip $(SDK.IAP.ARCHIVE)
	cd $(SDK.IAP.DIR) && chmod +x ./build*.sh

firmware.slot1.clean: .FORCE
	rm -rf $(FIRMWARE.SLOT1.BUILD)

firmware.slot2.clean: .FORCE
	rm -rf $(FIRMWARE.SLOT2.BUILD)


clean: toolchain.clean firmware.slot1.clean firmware.slot2.clean cmake.clean 
	rm -rf $(INSTALLED.HOST.DIR)
	rm -rf $(INSTALLED.TARGET.DIR)
	rm -rf $(DOWNLOADS.DIR)

.FORCE:


