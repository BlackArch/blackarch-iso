#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="blackarch-linux-slim"
iso_label="BLACKARCH_$(date +%Y%m)"
iso_publisher="BlackArch Linux <https://www.blackarch.org/>"
iso_application="BlackArch Linux Slim ISO"
iso_version="$(date +%Y.%m.%d)"
install_dir="blackarch"
bootmodes=('bios.syslinux.mbr' 'bios.syslinux.eltorito' 'uefi-x64.systemd-boot.esp' 'uefi-x64.systemd-boot.eltorito')
arch="x86_64"
pacman_conf="pacman.conf"
