#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="blackarch"
iso_label="BLACKARCH_$(date +%Y%m)"
iso_publisher="BlackArch <https://www.blackarch.org>"
iso_application="BlackArch Live/Rescue CD"
iso_version="$(date +%Y.%m.%d)"
install_dir="arch"
bootmodes=('bios.syslinux.mbr' 'bios.syslinux.eltorito' 'uefi-x64.systemd-boot.esp' 'uefi-x64.systemd-boot.eltorito')
arch="x86_64"
pacman_conf="pacman.conf"
