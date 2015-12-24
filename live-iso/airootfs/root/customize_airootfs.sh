#!/bin/bash

#set -e -u

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
su -c 'curl -k -s https://blackarch.org/strap.sh | sh' root

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

# default shell
su -c 'usermod -s /bin/bash root' root

# disable pc speaker beep
su -c 'echo "blacklist pcspkr" > /etc/modprobe.d/nobeep.conf' root

# download and install exploits
su -c 'sploitctl -f 0 -v' root

# temporary fixes for ruby based tools
su -c 'cd /usr/share/metasploit/ && bundle config build.nokogiri --use-system-libraries && bundle install --deployment' root
su -c 'cd /usr/share/arachni/ && bundle config build.nokogiri --use-system-libraries && bundle install --path vendor/bundle' root
su -c 'cd /usr/share/wpscan/ && bundle config build.nokogiri --use-system-libraries && bundle install --path vendor/bundle --without test development' root
su -c 'cd /usr/share/smbexec/ && bundle config build.nokogiri --use-system-libraries && bundle install --path vendor/bundle' root
su -c 'cd /usr/share/beef/ && bundle config build.nokogiri --use-system-libraries && bundle install --path vendor/bundle' root

# disable network stuff
rm /etc/udev/rules.d/81-dhcpcd.rules
systemctl disable dhcpcd sshd rpcbind.service

# remove not needed .desktop entries
su -c 'rm -rf /usr/share/xsessions/openbox-kde.desktop' root
su -c 'rm -rf /usr/share/xsessions/i3-with-shmlog.desktop' root

# remove special (not needed) scripts
su -c 'rm /etc/systemd/system/getty@tty1.service.d/autologin.conf' root
su -c 'rm /root/{.automated_script.sh,.zlogin}' root
su -c 'rm /etc/mkinitcpio-archiso.conf' root
su -c 'rm -r /etc/initcpio' root

# add install.txt file
su -c 'echo "type blackarch-install and follow the instructions" > /root/install.txt'
