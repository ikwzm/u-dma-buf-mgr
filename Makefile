# SPDX-License-Identifier: GPL-2.0 OR MIT
# Copyright (C) 2015-2022 Ichiro Kawazome

#
# For built-in kernel
# 
obj-$(CONFIG_U_DMA_BUF_MGR) += u-dma-buf-mgr.o

#
# Refer KERNEL_SRC variable to work with PetaLinux
#
ifdef KERNEL_SRC
  KERNEL_SRC_DIR  := $(KERNEL_SRC)
else
  KERNEL_SRC_DIR  ?= /lib/modules/$(shell uname -r)/build
endif

#
# For out of kernel tree variables
#
HOST_ARCH ?= $(shell uname -m | sed -e s/arm.*/arm/ -e s/aarch64.*/arm64/)
ARCH      ?= $(shell uname -m | sed -e s/arm.*/arm/ -e s/aarch64.*/arm64/)

ifeq ($(ARCH), arm)
 ifneq ($(HOST_ARCH), arm)
   CROSS_COMPILE  ?= arm-linux-gnueabihf-
 endif
endif
ifeq ($(ARCH), arm64)
 ifneq ($(HOST_ARCH), arm64)
   CROSS_COMPILE  ?= aarch64-linux-gnu-
 endif
endif

ifndef BUILD_TARGET
  ifdef KERNELVERSION
    KERNEL_VERSION_LT_5 ?= $(shell echo $(KERNELVERSION) | awk -F. '{print $$1 < 5}')
  else
    KERNEL_VERSION_LT_5 ?= $(shell awk '/^VERSION/{print int($$3) < 5}' $(KERNEL_SRC_DIR)/Makefile)
  endif
  ifeq ($(KERNEL_VERSION_LT_5), 1)
    BUILD_TARGET ?= modules
  else
    BUILD_TARGET ?= u-dma-buf-mgr.ko
    ifdef U_DMA_BUF_BUILD_DIR
      BUILD_TARGET += $(U_DMA_BUF_BUILD_DIR)/u-dma-buf.ko
    endif
  endif
endif

ifndef OBJ_MODULES
  OBJ_MODULES ?= obj-m+=u-dma-buf-mgr.o
  ifdef U_DMA_BUF_BUILD_DIR
    OBJ_MODULES += obj-m+=$(U_DMA_BUF_BUILD_DIR)/u-dma-buf.o
  endif
  ifdef U_DMA_BUF_SYMVERS
    OBJ_MODULES += KBUILD_EXTRA_SYMBOLS=$(U_DMA_BUF_SYMVERS)
  endif
endif

#
# For out of kernel tree rules
#
all:
	$(MAKE) -C $(KERNEL_SRC_DIR) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) M=$(PWD) $(OBJ_MODULES) $(BUILD_TARGET)

modules_install:
	$(MAKE) -C $(KERNEL_SRC_DIR) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) M=$(PWD) $(OBJ_MODULES) modules_install

clean:
	$(MAKE) -C $(KERNEL_SRC_DIR) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) M=$(PWD) clean

