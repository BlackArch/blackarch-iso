#!/bin/bash

set -e -u

sed -i 's/#\(en_US\.UTF-8\)/\1/' /etc/locale.gen
locale-gen

ln -sf /usr/share/zoneinfo/UTC /etc/localtime

usermod -s /usr/bin/zsh root
cp -aT /etc/skel/ /root/

#useradd -m -p "" -g users -G "adm,audio,floppy,log,network,rfkill,scanner,storage,optical,power,wheel" -s /usr/bin/zsh arch

chmod 750 /etc/sudoers.d
chmod 440 /etc/sudoers.d/g_wheel

sed -i "s/#Server/Server/g" /etc/pacman.d/mirrorlist
sed -i 's/#\(Storage=\)auto/\1volatile/' /etc/systemd/journald.conf

systemctl enable pacman-init.service choose-mirror.service

### blackarch related ###

# create the user directory for live session
if [ ! -d /root ]
then
	mkdir /root && chown root /root
fi

# copy files over to home
su -c "cp -r /etc/skel/.* /root/" root

# add signing keys
su -c 'pacman-key --init' root
su -c 'pacman-key -r 4345771566D76038C7FEB43863EC0ADBEA87E4E3' root
su -c 'pacman-key --lsign-key 4345771566D76038C7FEB43863EC0ADBEA87E4E3' root

# sync database
su -c 'pacman -Syy --noconfirm' root

su -c 'cp /usr/share/doc/blackarch-install-scripts/blackarch-install.txt /root/' root
