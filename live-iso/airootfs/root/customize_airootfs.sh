#!/bin/bash

# exit on error and undefined variables
set -eu

# set locale
sed -i 's/#\(en_US\.UTF-8\)/\1/' /etc/locale.gen
locale-gen

# set timezone
ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# enabling all mirrors
sed -i "s|#Server|Server|g" /etc/pacman.d/mirrorlist

# storing the system journal in RAM
sed -i 's/#\(Storage=\)auto/\1volatile/' /etc/systemd/journald.conf

# default releng configuration
sed -i 's/#\(HandleSuspendKey=\)suspend/\1ignore/' /etc/systemd/logind.conf
sed -i 's/#\(HandleHibernateKey=\)hibernate/\1ignore/' /etc/systemd/logind.conf
sed -i 's/#\(HandleLidSwitch=\)suspend/\1ignore/' /etc/systemd/logind.conf

# enable useful services and display manager
enabled_services=('choose-mirror.service' 'lxdm.service' 'dbus')
systemctl enable ${enabled_services[@]}
systemctl set-default graphical.target

# create the user directory for live session
if [ ! -d /root ]; then
    mkdir /root
    chmod 700 /root && chown -R root:root /root
fi

# disable pc speaker beep
echo "blacklist pcspkr" > /etc/modprobe.d/nobeep.conf

# disable network stuff
rm /etc/udev/rules.d/81-dhcpcd.rules
systemctl disable dhcpcd sshd rpcbind.service

# remove special (not needed) files
rm /etc/systemd/system/getty@tty1.service.d/autologin.conf
rm /root/{.automated_script.sh,.zlogin}

# setting root password
echo "root:blackarch" | chpasswd

# copy files over to home
cp -r /etc/skel/. /root/.

# setup repository, add pacman.conf entry, sync databases
curl -s https://blackarch.org/strap.sh | sh
pacman -Syy --noconfirm
pacman-key --init
pacman-key --populate blackarch archlinux
pkgfile -u
pacman -Fyy
pacman-db-upgrade
updatedb
sync

# font configuration
ln -sf /etc/fonts/conf.avail/* /etc/fonts/conf.d

# fix wrong permissions for blackarch-dwm
chmod 755 /usr/bin/blackarch-dwm

# default shell
chsh -s /bin/bash

# download and install exploits
sploitctl -f 0 -v

# temporary fixes for ruby based tools
cd /usr/share/arachni/ && bundle-2.3 config build.nokogiri --use-system-libraries && bundle-2.3 install --path vendor/bundle
cd /usr/share/smbexec/ && bundle config build.nokogiri --use-system-libraries && bundle install --path vendor/bundle
cd /usr/share/beef/ && bundle config build.nokogiri --use-system-libraries && bundle install --path vendor/bundle

# remove not needed .desktop entries
rm -rf /usr/share/xsessions/openbox-kde.desktop
rm -rf /usr/share/xsessions/i3-with-shmlog.desktop
rm -rf /usr/share/xsessions/xfce.desktop
rm -rf /root/install.txt

# add install.txt file
echo "Type blackarch-install and follow the instructions." > /root/INSTALL

# GDK Pixbuf
gdk-pixbuf-query-loaders --update-cache

# tmp fix for awesome exit()
sed -i 's|local visible, action = cmd(item, self)|local visible, action = cmd(0, 0)|' /usr/share/awesome/lib/awful/menu.lua
