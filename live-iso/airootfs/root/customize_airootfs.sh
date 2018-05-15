#!/bin/bash

# exit on error and undefined variables
set -eu

# set locale
sed -i 's/#\(en_US\.UTF-8\)/\1/' /etc/locale.gen
locale-gen

# set timezone
ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# enabling all mirros
sed -i "s|#Server|Server|g" /etc/pacman.d/mirrorlist

# storing the system journal in RAM
sed -i 's/#\(Storage=\)auto/\1volatile/' /etc/systemd/journald.conf

# default releng configuration
sed -i 's/#\(HandleSuspendKey=\)suspend/\1ignore/' /etc/systemd/logind.conf
sed -i 's/#\(HandleHibernateKey=\)hibernate/\1ignore/' /etc/systemd/logind.conf
sed -i 's/#\(HandleLidSwitch=\)suspend/\1ignore/' /etc/systemd/logind.conf

# enable useful services and display manager
enabled_services=('choose-mirror.service' 'lxdm.service' 'dbus'
                  'vmware-vmblock-fuse.service' 'vmtoolsd.service')
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
pacman -Syy --noconfirm
pacman-optimize
pacman-db-upgrade
pacman-key --init
# install BlackArch repository with default mirror (that's why the sed)
curl -s https://blackarch.org/strap.sh | \
    sed "s|get_mirror$|#get_mirror|1" | sh
pacman-key --populate blackarch archlinux

# font configuration
ln -sfv /etc/fonts/conf.avail/70-no-bitmaps.conf /etc/fonts/conf.d
ln -sfv /etc/fonts/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d
ln -sfv /etc/fonts/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d

# fix wrong permissions for blackarch-dwm
chmod 755 /usr/bin/blackarch-dwm

# default shell
chsh -s /bin/bash

# download and install exploits
sploitctl -f 0 -v

# temporary fixes for ruby based tools
cd /usr/share/arachni/ && bundle config build.nokogiri --use-system-libraries && bundle install --path vendor/bundle
cd /usr/share/smbexec/ && bundle config build.nokogiri --use-system-libraries && bundle install --path vendor/bundle
cd /usr/share/beef/ && bundle config build.nokogiri --use-system-libraries && bundle install --path vendor/bundle

# remove not needed .desktop entries
rm -rf /usr/share/xsessions/openbox-kde.desktop
rm -rf /usr/share/xsessions/i3-with-shmlog.desktop

# add install.txt file
echo "type blackarch-install and follow the instructions" > /root/install.txt

# GDK Pixbuf
gdk-pixbuf-query-loaders --update-cache
