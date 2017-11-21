# SnowWhiteOS
SnowWhiteOS, This will writing swift.

# Building
This is SnowWhiteOS is require for build.
- Swift (>= 4) (https://swift.org)
- NASM (http://www.nasm.us/)
- GCC Toolchain or GCC (https://gcc.gnu.org/)
- Clang (https://clang.llvm.org/)

## On Windows
I will add later

## On Mac
macOS is default ld is bsd ld (can not link SnowWhiteOS)\
and default as is clang too (build error)\
If you want build SnowWhiteOS on macOS\
- Need HomeBrew (https://brew.sh/)
- Need Xcode Command Line Tools (This will install both HomeBrew)
- Need NASM (can install in HomeBrew)
- Need QEMU (if you want run SnowWhiteOS)
```
$ /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
$ homebrew install nasm qemu
$ git clone https://github.com/SnowWhiteOS/mac-binutils-script.git
$ cd mac-binutils-script
$ sudo ./compile.sh
$ git clone https://github.com/SnowWhiteOS/SnowWhiteOS.git
$ cd SnowWhiteOS
$ make run
```

## On Linux
### Fedora
I will add later

# Thanks for
- https://stackoverflow.com/questions/27051471/call-c-kernel-from-assembly-bootloader/33263223#33263223
- https://github.com/rzhikharevich/swift-bare-bones
- https://github.com/klange/taylor
- https://github.com/charliesome/mini64
- https://github.com/apple/swift
