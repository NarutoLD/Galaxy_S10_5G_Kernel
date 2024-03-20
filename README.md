# Crecker Kernel for Samsung Galaxy : S10 5G (G977B)

Based on samsung sources and android common tree and the modified verison of Ivan meler

OneUI 4 and 5

## How to install

Backup your existing kernel. You will be able to restore it from TWRP Recovery in case of problems.
Then flash the zip package and the magisk zip.
Clean cache and reboot.

## GLORIFICATION

Geekbench Single core 	original: 867 	mine: 1025 --> exynos 990 Level
Geekbench Multi core 	original: 2162 	mine: 2601 --> Snapdragon 855 Level

## How to build the kernel on your PC

```sh
# Install prerequisites
$ sudo apt-get install build-essential libncurses-dev libtinfo5 bc bison flex libssl-dev libelf-dev heimdall-flash android-tools-adb android-tools-fastboot curl p7zip-full gcc g++

# Install avbtool
$ wget -q https://android.googlesource.com/platform/external/avb/+archive/refs/heads/master.tar.gz -O - | tar xzf - avbtool.py
$ chmod +x avbtool.py
$ sudo mv avbtool.py /usr/local/bin/avbtool

# Install mkbootimg
$ wget -q https://android.googlesource.com/platform/system/tools/mkbootimg/+archive/refs/heads/master.tar.gz -O - | tar xzf - mkbootimg.py gki
$ chmod +x mkbootimg.py
$ sudo mv mkbootimg.py /usr/local/bin/mkbootimg
$ sudo mv gki $(python -c 'import site; print(site.getsitepackages()[0])')

# Install mkdtboimg
$ wget -q https://android.googlesource.com/platform/system/libufdt/+archive/refs/heads/master.tar.gz -O - | tar --strip-components 2 -xzf - utils/src/mkdtboimg.py
$ chmod +x mkdtboimg.py
$ sudo mv mkdtboimg.py /usr/local/bin/mkdtboimg

# Get the sources
$ git clone https://github.com/Creeeeger/Galaxy_S10_5G_Kernel
$ cd Galaxy_S10_5G_Kernel

$ bash build.sh
```
----------------------------------------------------------------------------------------
