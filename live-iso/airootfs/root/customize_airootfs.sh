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
enabled_services=('choose-mirror.service' 'lxdm.service' 'dbus' 'wicd' 'iptables')
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
rm /etc/fonts/conf.d/05-reset-dirs-sample.conf
rm /etc/fonts/conf.d/09-autohint-if-no-hinting.conf

# default shell
chsh -s /bin/bash

# download and install exploits
mkdir -p /usr/share/exploits/exploit-db
sploitctl -f 0 -t 10 -XR

# temporary fixes for ruby based tools
cd /usr/share/arachni/ && rm -f Gemfile.lock &&
  bundle-2.3 config build.nokogiri --use-system-libraries &&
  bundle-2.3 install --path vendor/bundle && rm -f Gemfile.lock
cd /usr/share/smbexec/ && rm -f Gemfile.lock &&
  bundle config build.nokogiri --use-system-libraries &&
  bundle install --path vendor/bundle && rm -f Gemfile.lock
cd /usr/share/beef/ && rm -f Gemfile.lock &&
  bundle config build.nokogiri --use-system-libraries &&
  bundle install --path vendor/bundle && rm -f Gemfile.lock
cd /usr/share/catphish && rm -f Gemfile.lock &&
  bundle config build.nokogiri --use-system-libraries &&
  bundle install --path vendor/bundle && rm -f Gemfile.lock
cd /usr/share/wpbrute-rpc && rm -f Gemfile.lock
  bundle config build.nokogiri --use-system-libraries &&
  bundle install --without test development --path vendor/bundle &&
cd /usr/share/staekka && rm -f Gemfile.lock &&
  bundle config build.nokogiri --use-system-libraries &&
  build install --no-cache --deployment --path vendor/bundle &&
cd /usr/share/vane && rm -f Gemfile.lock &&
  bundle config build.nokogiri --use-system-libraries &&
  bundle install --without test development --path vendor/bundle &&
cd /usr/share/vcsmap && rm -f Gemfile.lock &&
  bundle config build.nokogiri --use-system-libraries &&
  bundle install --without test development --path vendor/bundle &&
cd /usr/share/vsaudit && rm -f Gemfile.lock &&
  bundle config build.nokogiri --use-system-libraries &&
  bundle install --path vendor/bundle && rm -f Gemfile.lock
cd /usr/share/whitewidow && rm -f Gemfile.lock &&
  bundle config build.nokogiri --use-system-libraries &&
  bundle install --path vendor/bundle && rm -f Gemfile.lock
cd /usr/share/sitediff && rm -f Gemfile.lock &&
  bundle config build.nokogiri --use-system-libraries &&
  bundle install --path vendor/bundle && rm -f Gemfile.lock
cd /usr/share/wordpress-exploit-framework && rm -f Gemfile.lock
  bundle config build.nokogiri --use-system-libraries &&
  bundle install --path vendor/bundle && rm -f Gemfile.lock
cd /usr/share/kautilya && rm -f Gemfile.lock &&
  bundle config build.nokogiri --use-system-libraries &&
  bundle install --path vendor/bundle && rm -f Gemfile.lockk
cd /usr/share/whatweb && rm -f Gemfile.lock &&
  bundle config build.nokogiri --use-system-libraries &&
  bundle install --path vendor/bundle && rm -f Gemfile.lock

# remove not needed .desktop entries
rm -rf /usr/share/xsessions/blackarch-dwm.desktop
rm -rf /usr/share/xsessions/openbox-kde.desktop
rm -rf /usr/share/xsessions/i3-with-shmlog.desktop
rm -rf /usr/share/xsessions/xfce.desktop
rm -rf /usr/share/xsessions/*gnome*.desktop
rm -rf /usr/share/xsessions/*kde*.desktop
rm -rf /root/install.txt

# add install.txt file
echo "Type blackarch-install and follow the instructions." > /root/INSTALL

# GDK Pixbuf
gdk-pixbuf-query-loaders --update-cache

# tmp fix for awesome exit()
sed -i 's|local visible, action = cmd(item, self)|local visible, action = cmd(0, 0)|' /usr/share/awesome/lib/awful/menu.lua

