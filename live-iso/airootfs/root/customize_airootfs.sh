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

# setup repository, add pacman.conf entry, sync databses
su -c 'curl -s http://blackarch.org/strap.sh | sh' root

# sys updates, cleanups, etc.
su -c 'pacman -Syyu --noconfirm' root
#su -c "pacman -Rscn \$(pacman -Qtdq)"
su -c 'pacman-optimize'
su -c 'updatedb'
su -c 'sync'
su -c 'pacman-db-upgrade' root
su -c 'pkgfile -u' root

# fix wrong permissions for blackarch-dwm
su -c 'chmod 755 /usr/bin/blackarch-dwm'

# blackarch-install info file
su -c 'cp /usr/share/doc/blackarch-install-scripts/blackarch-install.txt /root/' root
su -c 'rm -rf /root/install.txt' root

# default shell
su -c 'usermod -s /bin/bash root' root

# disable pc speaker beep
su -c 'echo "blacklist pcspkr" > /etc/modprobe.d/nobeep.conf' root

# download and install exploits
su -c 'sploitctl -f 0 -v' root

# temporary fixes for ruby based tools
su -c 'cd /usr/share/metasploit/ && bundle install' root
su -c 'cd /usr/share/arachni/ && bundle install' root
su -c 'cd /usr/share/wpscan/ && bundle install --without test development' root
su -c 'cd /usr/share/smbexec/ && bundle install' root
su -c 'cd /usr/share/beef/ && bundle install' root

# disable network stuff
rm /etc/udev/rules.d/81-dhcpcd.rules
systemctl disable dhcpcd sshd rpcbind.service

# remove not needed .destop entries
su -c 'rm -rf /usr/share/xsessions/openbox-kde.desktop' root
su -c 'rm -rf /usr/share/xsessions/i3-with-shmlog.desktop' root
