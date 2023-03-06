u-dma-buf-mgr
====================================================================================

Overview
------------------------------------------------------------------------------------

### Introduction

This repository provides kernel module to easily create or delete u-dma-buf.
Once this device driver is loaded into your system, you will be able to access `/dev/u-dma-buf-mgr`.
`u-dma-buf` can be created/deleted by writing the command to `/dev/u-dma-buf-mgr` as a string.

Udmabuf is a Linux device driver that allocates contiguous memory blocks in the kernel space as DMA buffers and makes them available from the user space.

For details of udmabuf, please refer to following URL.

https://github.com/ikwzm/udmabuf

Usage
------------------------------------------------------------------------------------

### Create u-dma-buf

#### Example

```console
shell$ sudo sh -c "echo 'create udmabuf8 0x10000' > /dev/u-dma-buf-mgr"
[16463.308265] u-dma-buf-mgr: create udmabuf8 size=65536
[16463.311147] u-dma-buf udmabuf8: driver version = 4.3.0
[16463.311148] u-dma-buf udmabuf8: major number   = 238
[16463.311149] u-dma-buf udmabuf8: minor number   = 0
[16463.311149] u-dma-buf udmabuf8: phys address   = 0x000000007b410000
[16463.311150] u-dma-buf udmabuf8: buffer size    = 65536
[16463.311150] u-dma-buf udmabuf8: dma device     = u-dma-buf.1.auto
[16463.311151] u-dma-buf udmabuf8: dma bus        = platform
[16463.311151] u-dma-buf udmabuf8: dma coherent   = 1
[16463.311152] u-dma-buf udmabuf8: dma mask       = 0x00000000ffffffff
[16463.311152] u-dma-buf u-dma-buf.1.auto: driver installed.
```

```console
shell$ sudo sh -c "echo 'create udmabuf9 0x10000 bus=pci device=0000:00:18.7' > /dev/u-dma-buf-mgr"
[18758.896248] u-dma-buf-mgr: create udmabuf9 size=65536
[18758.899611] u-dma-buf udmabuf0: driver version = 4.3.0
[18758.899612] u-dma-buf udmabuf0: major number   = 238
[18758.899613] u-dma-buf udmabuf0: minor number   = 0
[18758.899614] u-dma-buf udmabuf0: phys address   = 0x000000007b410000
[18758.899614] u-dma-buf udmabuf0: buffer size    = 65536
[18758.899615] u-dma-buf udmabuf0: dma device     = 0000:00:18.7
[18758.899615] u-dma-buf udmabuf0: dma bus        = pci
[18758.899626] u-dma-buf udmabuf0: dma coherent   = 1
[18758.899628] u-dma-buf udmabuf0: dma mask       = 0x00000000ffffffff
[18758.899628] u-dma-buf: driver installed.
```

#### Synopsis for writing /dev/u-dma-buf-mgr

```create <device-name> <size> [bus=<bus>] [device=<device>] [dma-mask=<dma-mask-size>]```

##### `device-name`

The `device-name` argument is used to set the name of device.
The `device-name` argument is mandatory.

##### `size`

The `size` argument is used to set the capacity of DMA buffer in bytes.
The `size` argment is mandatory.

##### `device` option

The `device` option specifies the parent device of u-dma-buf.
If the `device` option is omitted, it creates its own platform device.

##### `bus` option

The `bus` option specifies the bus to search for the device specified by the device option.
If the `bus` option is omitted, the platform bus is searched.

##### `dma-mask` option

The `dma-mask` option specifies the number of bits in the dma mask value.
If the parent device is specified by the `device` option, the `dma-mask` option is ignored because the dma-mask set for the parent device takes precedence.

### Delete u-dma-buf

#### Example

```console
shell$ sudo sh -c "echo 'delete udmabuf8' > /dev/u-dma-buf-mgr"
[16528.506714] u-dma-buf-mgr: delete udmabuf8
[16528.508506] u-dma-buf u-dma-buf.1.auto: driver removed.
```

#### Synopsis for writing /dev/u-dma-buf-mgr

```delete <device-name>```

##### `device-name`

The `device-name` argument is used to set the name of device.
The `device-name` argument is mandatory.
The `device-name` argument must be the device name created by the create command.

Install
------------------------------------------------------------------------------------

### Installation with command

Before installing u-dma-buf-mgr, u-dma-buf must be installed beforehand.

Load the u-dma-buf-mgr using insmod.

```console
shell$ sudo insmod u-dma-buf-mgr.ko
```

or load the u-dma-buf-mgr using modprobe.

```console
shell$ sudo modprobe u-dma-buf-mgr
```

The module can be uninstalled by the rmmod command.

```console
shell$ sudo rmmod  u-dma-buf-mgr
```

### Installation with the Debian Package

For details, refer to the following URL.

 * https://github.com/ikwzm/u-dma-buf-kmod-dpkg

Compile
------------------------------------------------------------------------------------

### Makefile

This repository contains a [Makefie](./Makefile).
Makefile has the following Parameters:

| Parameter Name             | Description                    | Default Value                        |
|----------------------------|--------------------------------|--------------------------------------|
| ARCH                       | Architecture Name              | `$(shell uname -m \| sed -e s/arm.*/arm/ -e s/aarch64.*/arm64/)` |
| KERNEL_SRC                 | Kernel Source Directory        | `/lib/modules/$(shell uname -r)/build` |
| U_DMA_BUF_SYMVERS          | u-dma-buf Module.symvers       | none |
| U_DMA_BUF_BUILD_DIR        | u-dma-buf Build Directory      | none |

Symbol information of functions/variables exported by u-dma-buf is required to compile u-dma-buf-mgr.
Therefore, either of the following two is required.

Set U_DMA_BUF_SYMVERS variable to Module.symvers created by u-dma-buf

Set U_DMA_BUF_BUILD_DIR variable to u-dma-buf's source code directory and build u-dma-buf at the same time.

### Cross Compile

If you have a cross-compilation environment for target system, you can compile with:

```console
shell$ make ARCH=arm KERNEL_SRC=/home/fpga/src/linux-5.10.109-armv7-fpga U_DMA_BUF_BUILD_DIR=../udmabuf/ all
make -C /home/fpga/src/linux-5.10.109-armv7-fpga ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- M=/home/fpga/src/u-dma-buf-mgr obj-m+=u-dma-buf-mgr.o obj-m+=../udmabuf//u-dma-buf.o u-dma-buf-mgr.ko ../udmabuf//u-dma-buf.ko
make[1]: Entering directory '/home/fpga/src/linux-5.10.109-armv7-fpga'
  CC [M]  /home/fpga/src/u-dma-buf-mgr/../udmabuf//u-dma-buf.o
  MODPOST /home/fpga/src/u-dma-buf-mgr/Module.symvers
  CC [M]  /home/fpga/src/u-dma-buf-mgr/../udmabuf//u-dma-buf.mod.o
  LD [M]  /home/fpga/src/u-dma-buf-mgr/../udmabuf//u-dma-buf.ko
  CC [M]  /home/fpga/src/u-dma-buf-mgr/u-dma-buf-mgr.mod.o
  LD [M]  /home/fpga/src/u-dma-buf-mgr/u-dma-buf-mgr.ko
make[1]: Leaving directory '/home/fpga/src/linux-5.10.109-armv7-fpga'
```

The ARCH variable specifies the architecture name.    
The KERNEL_SRC variable specifies the Linux Kernel source code path.
The U_DMA_BUF_BUILD_DIR variable sepcifies the u-dma-buf build directory.

```console
shell$ make ARCH=arm KERNEL_SRC=/home/fpga/src/linux-5.10.120-zynqmp-fpga-generic U_DMA_BUF_SYMVERS=/home/fpga/src/udmabuf/Module.symvers all
make -C /home/fpga/src/linux-5.10.109-armv7-fpga ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- M=/home/fpga/src/u-dma-buf-mgr obj-m+=u-dma-buf-mgr.o KBUILD_EXTRA_SYMBOLS=/home/fpga/src/udmabuf/Module.symvers u-dma-buf-mgr.ko
make[1]: Entering directory '/home/fpga/src/linux-5.10.109-armv7-fpga'
  MODPOST /home/fpga/src/u-dma-buf-mgr/Module.symvers
  CC [M]  /home/fpga/src/u-dma-buf-mgr/u-dma-buf-mgr.mod.o
  LD [M]  /home/fpga/src/u-dma-buf-mgr/u-dma-buf-mgr.ko
make[1]: Leaving directory '/home/fpga/src/linux-5.10.109-armv7-fpga'
```
The ARCH variable specifies the architecture name.    
The KERNEL_SRC variable specifies the Linux Kernel source code path.
The U_DMA_BUF_SYMVERS variable sepcifies the u-dma-buf Module.symbers file.

### Self Compile

If your target system is capable of self-compiling the Linux Kernel module, you can compile it with:

```console
shell$ make U_DMA_BUF_SYMVERS=/home/fpga/src/u-dma-buf/Module.symvers all
```
You need the kernel source code in ```/lib/modules/$(shell uname -r)/build``` to compile.


### Build in Linux Source Tree

It can also be compiled into the Linux Kernel Source Tree.

#### Make directory in Linux Kernel Source Tree.

```console
shell$ mkdir <linux-source-tree>/drivers/staging/u-dma-buf-mgr
```

#### Copy files to Linux Kernel Source Tree.

```console
shell$ cp Kconfig Makefile u-dma-buf.c <linux-source-tree>/drivers/staging/u-dma-buf-mgr
```

#### Add u-dma-buf-mgr to Kconfig

```console
shell$ diff <linux-source-tree>/drivers/staging/Kconfig
  :
 source "drivers/staging/u-dma-buf/Kconfig"
+source "drivers/staging/u-dma-buf-mgr/Kconfig"
+
```

#### Add u-dma-buf to Makefile

```Makefile
shell$ diff <linux-source-tree>/drivers/staging/Makefile
  :
 obj-$(CONFIG_U_DMA_BUF)     += u-dma-buf/
+obj-$(CONFIG_U_DMA_BUF_MGR) += u-dma-buf-mgr/
```

#### Set CONFIG_U_DMA_BUF

For make menuconfig, set the following:

```console
Device Drivers --->
  Staging drivers --->
    <M> u-dma-buf(User space mappable DMA Buffer) --->
```

####  Set CONFIG_U_DMA_BUF_MGR

```console
--- u-dma-buf(User space mappable DMA Buffer) 
<M> u-dma-buf-mgr(User space mappable DMA Buffer Manager)
```console


If you write it directly in defconfig:

```console
shell$ diff <linux-source-tree>/arch/arm64/configs/xilinx_zynqmp_defconfig
   :
+CONFIG_U_DMA_BUF=m
+CONFIG_U_DMA_BUF_MGR=m
```
