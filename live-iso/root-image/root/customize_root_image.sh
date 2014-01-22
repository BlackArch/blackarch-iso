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

# add signing keys and setup pacman.conf
su -c 'pacman-key --init' root
su -c 'pacman-key --populate' root
su -c 'chmod 700 /etc/pacman.d/gnupg' root
su -c 'wget http://blackarch.org/blackarch/blackarch/os/x86_64/blackarch-keyring-20140118-3-any.pkg.tar.xz{,.sig}' root
su -c "gpg --keyserver hkp://pgp.mit.edu --recv-keys '4345771566D76038C7FEB43863EC0ADBEA87E4E3'" root
su -c 'gpg --with-fingerprint --verify blackarch-keyring-20140118-3-any.pkg.tar.xz.sig' root
su -c 'rm -rf blackarch-keyring-20140118-3-any.pkg.tar.xz.sig' root
su -c 'pacman --noconfirm -U blackarch-keyring-20140118-3-any.pkg.tar.xz' root
su -c "echo '[blackarch]' >> /etc/pacman.conf" root
su -c "echo 'Server = http://www.blackarch.org/blackarch/\$repo/os/\$arch' >> /etc/pacman.conf" root

# sync database
su -c 'pacman -Syyu --noconfirm' root

# fix wrong permissions for blackarch-dwm
su -c 'chmod 755 /usr/local/bin/blackarch-dwm'

# blackarch-install (dev version)
su -c 'rm -rf /usr/share/blackarch-install-scripts' root
su -c 'cd /usr/share/; git clone https://github.com/BlackArch/blackarch-install-scripts' root
su -c 'cp /usr/share/doc/blackarch-install-scripts/blackarch-install.txt /root/' root
su -c 'rm -rf /root/install.txt' root

# temporary fix for metasploit
su -c 'cd /usr/share/metasploit/ && bundle-1.9 install' root
