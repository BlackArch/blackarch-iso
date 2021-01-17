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
enabled_services=('choose-mirror.service' 'lightdm.service' 'dbus' 'pacman-init' 'NetworkManager' 'irqbalance')
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
rm -f /etc/udev/rules.d/81-dhcpcd.rules
systemctl disable dhcpcd sshd rpcbind.service

# remove special (not needed) files
rm -f /etc/systemd/system/getty@tty1.service.d/autologin.conf
rm /root/{.automated_script.sh,.zlogin}

# setting root password
echo "root:blackarch" | chpasswd
passwd -l root
chsh -s /usr/bin/nologin

# copy config files to skel
cp /usr/share/blackarch/config/bash/bashrc /etc/skel/.bashrc
cp /usr/share/blackarch/config/bash/bash_profile /etc/skel/.bash_profile
cp -a /usr/share/blackarch/config/zsh/zsh /etc/skel/.zsh
cp /usr/share/blackarch/config/zsh/zshrc /etc/skel/.zshrc

# setup user
useradd -m -g users -G wheel,power,audio,video,storage -s /bin/zsh liveuser
echo "liveuser:blackarch" | chpasswd
ln -sf /usr/share/icons/blackarch-icons/apps/scalable/distributor-logo-blackarch.svg /home/liveuser/.face

# copy files over to home
cp -r /etc/skel/. /root/.

# font configuration
ln -sf /etc/fonts/conf.avail/* /etc/fonts/conf.d
rm -f /etc/fonts/conf.d/05-reset-dirs-sample.conf
rm -f /etc/fonts/conf.d/09-autohint-if-no-hinting.conf

# temporary fixes for ruby based tools
cd /usr/share/whatweb && rm -f Gemfile.lock &&
  bundle config build.nokogiri --use-system-libraries &&
  bundle install --path vendor/bundle && rm -f Gemfile.lock

# GDK Pixbuf
gdk-pixbuf-query-loaders --update-cache
