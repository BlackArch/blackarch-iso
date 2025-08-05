#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="blackarch-linux-netinst"
iso_label="BLACKARCH_$(date +%Y%m)"
iso_publisher="BlackArch Linux <https://www.blackarch.org/>"
iso_application="BlackArch Linux NetInstall ISO"
iso_version="$(date +%Y.%m.%d)"
install_dir="blackarch"
bootmodes=('bios.syslinux.mbr' 'bios.syslinux.eltorito' 'uefi-x64.systemd-boot.esp' 'uefi-x64.systemd-boot.eltorito')
arch="x86_64"
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86' '-b' '1M' '-Xdict-size' '1M')
file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/root"]="0:0:750"
)

