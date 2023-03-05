u-dma-buf-mgr
====================================================================================

Overview
------------------------------------------------------------------------------------

### Introduction

This repository provides kernel module to easily create or delete u-dma-buf.

Udmabuf is a Linux device driver that allocates contiguous memory blocks in the kernel space as DMA buffers and makes them available from the user space.

For details of udmabuf, please refer to following URL.

https://github.com/ikwzm/udmabuf

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
