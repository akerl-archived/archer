#!/usr/bin/env bash

parted -ms /dev/vda rm 1
parted -ms /dev/vda rm 2

size=$(parted -ms /dev/vda unit MB print | tail -n1 | sed 's/[^:]*://;s/MB.*//')
swapsize=256
let rootsize=$size-$swapsize

parted -ms -a optimal /dev/vda mkpart primary ext3 1 $rootsize
parted -ms -a optimal /dev/vda mkpart primary linux-swap $rootsize $size

mkfs.ext3 /dev/vda1
mkswap /dev/vda2

mount /dev/vda1 /mnt
swapon /dev/vda2

pacstrap /mnt base base-devel git jshon python python-pip openssh wget
genfstab -p /mnt >> /mnt/etc/fstab

arch-chroot /mnt <<EOF
  git clone git://github.com/keenerd/packer.git /opt/packer
  chmod a+x /opt/packer/packer
  /opt/packer/packer -S grub-legacy --noconfirm
  cp /usr/lib/grub/i386-pc/* /boot/grub/
  echo "device (hd0) /dev/vda1
root (hd0,0)
setup (hd0)
" | grub --no-curses
  git clone git://github.com/akerl/roller.git /opt/roller
  git clone git://github.com/akerl/kernels.git /opt/roller/configs
  pip install sh
  rm /boot/grub/menu.lst
  /opt/roller/autoroll.py
  systemctl enable sshd.service
  systemctl enable dhcpcd.service
  rm -rf /opt/roller
  rm -rf /opt/packer
  mkdir -p /root/.ssh
  wget -O /root/.ssh/authorized_keys 'https://raw.github.com/akerl/keys/master/ender.pub'
EOF

umount /mnt
swapoff

