#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="blackarch-linux-full"
iso_label="BLACKARCH_$(date +%Y%m)"
iso_publisher="BlackArch Linux <https://www.blackarch.org/>"
iso_application="BlackArch Linux Full ISO"
iso_version="$(date +%Y.%m.%d)"
install_dir="blackarch"
bootmodes=('bios.syslinux' 'uefi.systemd-boot')
arch="x86_64"
pacman_conf="pacman.conf"
# The airootfs overlay is copied with --no-preserve=mode, so nothing in it keeps
# its execute bit unless it is listed here.
declare -A file_permissions=(
  ["/etc/systemd/scripts/choose-mirror"]="0:0:755"
  ["/usr/local/bin/blackarch-set-wallpaper"]="0:0:755"
  ["/usr/share/blackarch-menu/BlackArchXfceMenuTool.py"]="0:0:755"
  ["/usr/share/blackarch-menu/regen-menu.sh"]="0:0:755"
)
