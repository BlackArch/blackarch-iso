#!/bin/bash

# exit on error and undefined variables
set -eu

# set locale
sed -i 's/#\(en_US\.UTF-8\)/\1/' /etc/locale.gen
locale-gen

# set timezone
ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# enabling all mirrors
#sed -i "s|#Server|Server|g" /etc/pacman.d/mirrorlist
sed -i 's|#Server https://ftp.halifax|Server https://ftp.halifax|g' \
  /etc/pacman.d/mirrorlist

# storing the system journal in RAM
sed -i 's/#\(Storage=\)auto/\1volatile/' /etc/systemd/journald.conf

# default releng configuration
sed -i 's/#\(HandleSuspendKey=\)suspend/\1ignore/' /etc/systemd/logind.conf
sed -i 's/#\(HandleHibernateKey=\)hibernate/\1ignore/' /etc/systemd/logind.conf
sed -i 's/#\(HandleLidSwitch=\)suspend/\1ignore/' /etc/systemd/logind.conf

# enable useful services and display manager
enabled_services=('choose-mirror.service' 'lightdm.service' 'dbus' 'pacman-init'
  'NetworkManager' 'irqbalance' 'vboxservice')
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
rm -f /root/{.automated_script.sh,.zlogin}

# xfce desktop backdrop
#
# blackarch-config-xfce ships an xfce4-desktop.xml that xfconf cannot parse: its
# <property name="tooltip-size"> tag is never closed, so the whole channel is
# discarded and the desktop comes up bare. It also points at
# /usr/share/backgrounds/blackarch.png, which no package installs. Both are fixed
# in the replacement below. This has to happen before liveuser is created, since
# useradd -m snapshots /etc/skel as it stands at that moment.
install -Dm644 /usr/local/share/blackarch-xfce/xfce4-desktop.xml \
  /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml

# setting root password
echo "root:blackarch" | chpasswd

# setup user
useradd -m -g users -G wheel,power,audio,video,storage -s /bin/bash liveuser
echo "liveuser:blackarch" | chpasswd
ln -sf /usr/share/icons/blackarch-icons/apps/scalable/distributor-logo-blackarch.svg \
  /home/liveuser/.face

# copy files over to home
cp -r /etc/skel/. /root/.

# setup repository, add pacman.conf entry, sync databases
curl -s https://blackarch.org/strap.sh | sh
pacman -Syy --noconfirm
pacman-key --init
pacman-key --populate blackarch archlinux
#pkgfile -u
pacman -Fyy
pacman-db-upgrade
updatedb
sync

# font configuration
ln -sf /etc/fonts/conf.avail/* /etc/fonts/conf.d
rm -f /etc/fonts/conf.d/05-reset-dirs-sample.conf
rm -f /etc/fonts/conf.d/09-autohint-if-no-hinting.conf

# default shell
chsh -s /bin/bash

# download and install exploits, but remove bin-sploits from exploit-db
sploitctl -f 1 -t 5 -r 2 -XR
sploitctl -f 2 -t 5 -r 2 -XR
sploitctl -f 3 -t 5 -r 2 -XR
rm -rf /usr/share/exploits/exploit-db/exploitdb-bin-sploits

# temporary fixes for ruby based tools
cd /usr/share/automato && rm -f Gemfile.lock &&
  bundle config build.nokogiri --use-system-libraries &&
  bundle install --path vendor/bundle && rm -f Gemfile.lock
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
rm -f /usr/share/xsessions/blackarch-dwm.desktop
rm -f /usr/share/xsessions/openbox-kde.desktop
rm -f /usr/share/xsessions/i3-with-shmlog.desktop
rm -f /usr/share/xsessions/*gnome*.desktop
rm -f /usr/share/xsessions/*kde*.desktop
rm -f /root/install.txt

# add install.txt file
echo "Type blackarch-install and follow the instructions." > /root/INSTALL

# generate menu entries for every installed BlackArch tool
#
# Xfce draws its menu from XDG .desktop files, and the ~2900 CLI tools here ship
# none -- only the handful of GUI packages do, which is why the launcher came up
# with barely anything in it. blackarch-menus is meant to fill that gap, but its
# generator cannot during a build: it resolves each package with
# `pacman -Si blackarch/<pkg>`, and [blackarch] is not configured in this image
# until strap.sh runs above, long after its post-transaction hook has fired
# during pacstrap. Every lookup failed, so it wrote nothing at all.
#
# The generator below reads the local database instead, so it needs no repository
# and no network. It also resolves each package's real binary rather than
# assuming it matches the package name, which blackarch-menus does via TryExec --
# silently hiding every entry where the two differ.
#
# DO NOT add [blackarch] to this image's /etc/pacman.conf to "fix" that. It looks
# harmless and it is not: configuring the repository makes those failing lookups
# start succeeding, so blackarch-menus' hook does its full per-package loop during
# pacstrap -- roughly ten forks times every package in the transaction, which
# exhausts the process limit and takes the build down with it. The repository is
# added by strap.sh above, after pacstrap, which is exactly late enough.
#
# Drop blackarch-menus' fragment, hooks and any entries they produced first, so
# its tree does not sit alongside the generated one. Its .directory files are
# left alone: unreferenced once the fragment is gone, and package-owned.
rm -f /etc/xdg/menus/applications-merged/X-BlackArch.menu
rm -f /etc/pacman.d/hooks/blackarch-gen-desktop.hook
rm -f /etc/pacman.d/hooks/blackarch-rem-desktop.hook
rm -f /usr/share/applications/ba-*.desktop

# Install our own regeneration hook now, after pacstrap, so that it takes effect
# only in the booted system and never during the build. See the header comment in
# the staged copy for why it is not shipped in the overlay directly.
install -Dm644 /usr/local/share/blackarch-xfce/blackarch-xfce-menu.hook \
  /etc/pacman.d/hooks/blackarch-xfce-menu.hook

if ! python3 /usr/share/blackarch-menu/BlackArchXfceMenuTool.py --system --nested
then
  echo "WARNING: BlackArch menu generation failed, the Xfce menu will be sparse" >&2
fi

# GDK Pixbuf
gdk-pixbuf-query-loaders --update-cache

# tmp fix for awesome exit()
sed -i 's|local visible, action = cmd(item, self)|local visible, action = cmd(0, self)|' /usr/share/awesome/lib/awful/menu.lua

# fluxbox
rm -rf /usr/share/fluxbox
cp -r /root/.fluxbox /usr/share/fluxbox

# /etc
echo 'BlackArch Linux' > /etc/arch-release

# vim
cp -r /usr/share/blackarch/config/vim/vim /root/.vim
cp /usr/share/blackarch/config/vim/vimrc /root/.vimrc

