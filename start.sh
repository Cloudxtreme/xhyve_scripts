#!/bin/sh

HOSTNAME="blue-mage5"
HOSTROOT=$XHYVE_HOME/$HOSTNAME
echo $HOSTROOT
KERNEL="$HOSTROOT/boot/vmlinuz-linux"
INITRD="$HOSTROOT/boot/initramfs-linux.img"
CMDLINE="console=ttyS0 acpi=on root=/dev/vda2 ro"
#CMDLINE="acpi=off root=/dev/vda2 ro"

MEM="-m 2G"
#SMP="-c 2"
NET="-s 2:0,virtio-net"
IMG_HDD0="-s 4,virtio-blk,$HOSTROOT/storage/blue-mage5-root.img"
IMG_HDD1="-s 5,virtio-blk,$HOSTROOT/storage/docker_data.img"
PCI_DEV="-s 0:0,hostbridge -s 31,lpc"
LPC_DEV="-l com1,stdio"
UUID="43bd1b77-1571-4437-bf3e-160ed5b5ba6e"

sudo xhyve $MEM $SMP $PCI_DEV $LPC_DEV $NET $IMG_CD $IMG_HDD0 $IMG_HDD1 -U $UUID -f kexec,$KERNEL,$INITRD,"$CMDLINE" #& disown 2>&1
