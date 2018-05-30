#!/bin/bash

# exit on error and undefined variables
set -eu

# set locale
sed -i 's/#\(en_US\.UTF-8\)/\1/' /etc/locale.gen
locale-gen

# set timezone
ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# enabling all mirrors
sed -i "s/#Server/Server/g" /etc/pacman.d/mirrorlist

# storing the system journal in RAM
sed -i 's/#\(Storage=\)auto/\1volatile/' /etc/systemd/journald.conf

# default releng configuration
sed -i 's/#\(HandleSuspendKey=\)suspend/\1ignore/' /etc/systemd/logind.conf
sed -i 's/#\(HandleHibernateKey=\)hibernate/\1ignore/' /etc/systemd/logind.conf
sed -i 's/#\(HandleLidSwitch=\)suspend/\1ignore/' /etc/systemd/logind.conf

# enable useful services and display manager
systemctl enable pacman-init.service choose-mirror.service

# create the user directory for live session
if [ ! -d /root ]; then
  mkdir /root
  chmod 700 root && chown -R root:root /root
fi

# setting root password
echo "root:blackarch" | chpasswd

# copy files over to home
cp -r /etc/skel/. /root/.

# setup repository, add pacman.conf entry and sync databse
curl -s https://blackarch.org/strap.sh | sh
#curl -s https://blackarch.org/strap.sh | sed "s|get_mirror$|#get_mirror|1" | sh

# sys updates, cleanups, etc.
pacman -Syyu --noconfirm
pacman-db-upgrade
updatedb
pkgfile -u
sync

# default shell
chsh -s /bin/bash

# disable pc speaker beep
echo "blacklist pcspkr" > /etc/modprobe.d/nobeep.conf

# remove special (not needed) scripts
rm /etc/systemd/system/getty@tty1.service.d/autologin.conf
rm /root/{.automated_script.sh,.zlogin}
rm /etc/mkinitcpio-archiso.conf
rm -r /etc/initcpio

# add install.txt file
echo "Type blackarch-install and follow the instructions." > /root/INSTALL
rm -rf /root/install.txt
