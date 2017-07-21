#!/bin/bash


# This script serves the purpose to work with Modules Factory Proxmox module
# for WHMCS to reset root password for KVM template virtual machines. This
# script can 1) set root password on provision before the first boot of the
# virtual machine, 2) reset password when user changes root password in the
# client area using Modules Factory Proxmox module.


IN=$@
IFS=',' read varvmid varhostname varusername varpassword varmac varip varnode <<< "$IN";IFS='=' read var1 vmid <<< "$varvmid";IFS='=' read var2 hostname <<< "$varhostname";IFS='=' read var3 password <<< "$varpassword";IFS='=' read var4 username <<< "$varusername";IFS='=' read var5 macs <<< "$varmac";IFS='=' read var6 ips <<< "$varip";IFS='=' read var7 node <<< "$varnode"

lvm_driver=$(lvs | grep $vmid | awk '{print $1}')
lvm_vg=$(lvs | grep $vmid | awk '{print $2}')

kpartx -a "/dev/$lvm_vg/$lvm_driver"
lvchange -ay "/dev/mapper/$lvm_vg-vm--$vmid--disk--1p2"
mkdir -p /mnt/a
mount "/dev/mapper/$lvm_vg-vm--$vmid--disk--1p2" /mnt/a
cd /mnt/a

chroot /mnt/a sh -c "echo 'root:$password' | chpasswd"

cd "/mnt"
umount "/dev/mapper/$lvm_vg-vm--$vmid--disk--1p2"
kpartx -d "/dev/$lvm_vg/$lvm_driver"
lvchange -an "/dev/mapper/$lvm_vg-vm--$vmid--disk--1p2"
rm -r /mnt/a
