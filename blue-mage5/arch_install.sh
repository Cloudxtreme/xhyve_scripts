#!/bin/sh

HOSTNAME="blue-mage5"

XHYVE_BIN=/Users/cpk/.local/bin/xhyve
XHYVE_ROOT=/Users/cpk/virtual_machines/xhyve
VM_ROOT=${XHYVE_ROOT}/${HOSTNAME}
VM_STORAGE=${VM_ROOT}/storage
VM_DISTRO=${VM_ROOT}/distro

if [ ! -e $VM_STORAGE/${HOSTNAME}.img ]; then
	printf "Creating storage volume...\n"
	dd if=/dev/zero of=${VM_STORAGE}/${HOSTNAME}.img bs=1g count=5;
else
	printf "Storage volume already exits! :)\n";
fi

for iso in ${VM_DISTRO}/*.iso; do
	if [ -e ${iso} ]; then
		VM_ISO=${iso};
	else
		printf "Sorry, no distribution ISO is availabe :(\n";
		printf "Make sure ${VM_DISTRO} is populated\n";
		exit 1;
	fi
done

echo ${VM_ISO}

TMP_ISO=/tmp/${HOSTNAME}-tmp.iso

if [ ! -e ${TMP_ISO} ]; then
	dd if=/dev/zero of=${TMP_ISO} bs=2k count=1;
	dd if=${VM_ISO} bs=2k skip=1 >> ${TMP_ISO};
else
	printf "${TMP_ISO} already exists! Great! :)\n"
fi

OSXDISK=$(hdiutil attach ${TMP_ISO} | awk '{print $1}')
VOLUME=$(diskutil list ${OSXDISK} | tail -n 1 | awk '{print $2}')

cp /Volumes/${VOLUME}/arch/boot/x86_64/vmlinuz ${VM_DISTRO}
cp /Volumes/${VOLUME}/arch/boot/x86_64/archiso.img ${VM_DISTRO}
diskutil eject ${OSXDISK}

KERNEL="${VM_DISTRO}/vmlinuz"
INITRD="${VM_DISTRO}/archiso.img"
CMDLINE="earlyprintk=serial console=ttyS0 acpi=off archisolabel=${VOLUME}"

VM_ROOT_DISK="${1:-${VM_STORAGE}/${HOSTNAME}.img}"
echo $VM_ROOT_DISK

MEM="-m 1G"
#SMP="-c 2"
NET="-s 2:0,virtio-net"
IMG_CD="-s 3,ahci-cd,${VM_ISO}"
#IMG_HDD="-s 4,virtio-blk,${VM_STORAGE}/${HOSTNAME}.img"
IMG_HDD="-s 4,virtio-blk,${VM_ROOT_DISK}"
PCI_DEV="-s 0:0,hostbridge -s 31,lpc"
LPC_DEV="-l com1,stdio"
#
sudo ${XHYVE_BIN} ${MEM} ${SMP} ${PCI_DEV} ${LPC_DEV} ${NET} ${IMG_CD} ${IMG_HDD} -f kexec,${KERNEL},${INITRD},"${CMDLINE}"
