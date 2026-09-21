#!/bin/bash

# exit on error and undefined variables
set -eu

# live session user (must match removeuser.conf in blackarch-config-calamares)
readonly LIVE_USER="blackarch"
readonly LIVE_PASS="blackarch"
readonly LIVE_GROUP="users"
readonly LIVE_HOME="/home/${LIVE_USER}"
readonly LIVE_SESSION="xfce"

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

# default releng configuration
sed -i 's/#\(HandleSuspendKey=\)suspend/\1ignore/' /etc/systemd/logind.conf
sed -i 's/#\(HandleHibernateKey=\)hibernate/\1ignore/' /etc/systemd/logind.conf
sed -i 's/#\(HandleLidSwitch=\)suspend/\1ignore/' /etc/systemd/logind.conf

# enable useful services and display manager
enabled_services=('choose-mirror.service' 'lightdm.service' 'dbus' 'pacman-init'
  'NetworkManager' 'irqbalance' 'vboxservice' 'vmtoolsd' 'vmware-vmblock-fuse')
systemctl enable "${enabled_services[@]}"
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

# setting root password
echo "root:${LIVE_PASS}" | chpasswd

# copy config files to skel
cp /usr/share/blackarch/config/bash/bashrc /etc/skel/.bashrc
cp /usr/share/blackarch/config/bash/bash_profile /etc/skel/.bash_profile
cp /usr/share/blackarch/config/zsh/zshrc /etc/skel/.zshrc

# setup user
ln -sf /usr/share/icons/blackarch-icons/apps/scalable/distributor-logo-blackarch.svg /etc/skel/.face
getent group autologin > /dev/null || groupadd -r autologin
useradd -m -g "$LIVE_GROUP" -G wheel,power,audio,video,storage,autologin \
  -s /bin/zsh "$LIVE_USER"
echo "${LIVE_USER}:${LIVE_PASS}" | chpasswd
mkdir -p "${LIVE_HOME}/Desktop"
ln -sf /usr/share/applications/calamares.desktop "${LIVE_HOME}/Desktop/calamares.desktop"
sed -i -e "s|Install System|Install BlackArch|g" /usr/share/applications/calamares.desktop
ln -sf /usr/share/applications/xfce4-terminal-emulator.desktop "${LIVE_HOME}/Desktop/terminal.desktop"
chmod 755 "${LIVE_HOME}/Desktop"

# lightdm autologin for the live session
sed -i \
  -e "s/^#\?autologin-user=.*/autologin-user=${LIVE_USER}/" \
  -e "s/^#\?autologin-session=.*/autologin-session=${LIVE_SESSION}/" \
  -e "s/^#\?greeter-session=.*/greeter-session=lightdm-gtk-greeter/" \
  /etc/lightdm/lightdm.conf

# fail the build if the edit didn't apply
grep -q "^autologin-user=${LIVE_USER}$" /etc/lightdm/lightdm.conf
grep -q "^autologin-session=${LIVE_SESSION}$" /etc/lightdm/lightdm.conf
[ -f "/usr/share/xsessions/${LIVE_SESSION}.desktop" ]

# copy files over to home
cp -r /etc/skel/. /root/.

# repo + database
curl -s https://blackarch.org/strap.sh | sh
pacman -Syy --noconfirm
pacman-key --init
pacman-key --populate blackarch archlinux
pacman -Fyy
pacman-db-upgrade
updatedb
sync

# font configuration
ln -sf /etc/fonts/conf.avail/* /etc/fonts/conf.d
rm -f /etc/fonts/conf.d/05-reset-dirs-sample.conf
rm -f /etc/fonts/conf.d/09-autohint-if-no-hinting.conf

# temporary fixes for ruby based tools
(
  cd /usr/share/whatweb && rm -f Gemfile.lock &&
    bundle config set build.nokogiri --use-system-libraries &&
    bundle config set path 'vendor/bundle' && rm -f Gemfile.lock
)

# change default jdk
if archlinux-java status >/dev/null 2>&1; then
  current_java_env=$(archlinux-java status | awk '/^Available Java environments:/{flag=1; next} flag && /\(default\)$/{print $1; exit}')
  if [ -n "${current_java_env:-}" ]; then
    archlinux-java set "$current_java_env"
  fi
fi

# Temporary fix for calamares
#pacman -U --noconfirm https://archive.archlinux.org/packages/d/dosfstools/dosfstools-4.1-3-x86_64.pkg.tar.xz

# GDK Pixbuf
gdk-pixbuf-query-loaders --update-cache

# /etc
echo 'BlackArch Linux' > /etc/arch-release

# vim
cp -r /usr/share/blackarch/config/vim/vim "${LIVE_HOME}/.vim"
cp /usr/share/blackarch/config/vim/vimrc "${LIVE_HOME}/.vimrc"

# everything in the live user's home must belong to the live user
chown -R "${LIVE_USER}:${LIVE_GROUP}" "$LIVE_HOME"
