#!/bin/bash
#
# SPDX-License-Identifier: GPL-3.0-or-later

set -e -u

# Control the environment
umask 0022
export LANG="C"
export SOURCE_DATE_EPOCH="${SOURCE_DATE_EPOCH:-"$(date +%s)"}"

# mkarchiso defaults
app_name="${0##*/}"
pkg_list=()
run_cmd=""
quiet="y"
work_dir="work"
out_dir="out"
img_name="${app_name}.iso"
sfs_mode="sfs"
sfs_comp="xz"
gpg_key=""
override_gpg_key=""

# profile defaults
profile=""
iso_name="${app_name}"
iso_label="${app_name^^}"
override_iso_label=""
iso_publisher="${app_name}"
override_iso_publisher=""
iso_application="${app_name} iso"
override_iso_application=""
iso_version=""
install_dir="${app_name}"
override_install_dir=""
arch="$(uname -m)"
pacman_conf="/etc/pacman.conf"
override_pacman_conf=""
bootmodes=()


# Show an INFO message
# $1: message string
_msg_info() {
    local _msg="${1}"
    [[ "${quiet}" == "y" ]] || printf '[%s] INFO: %s\n' "${app_name}" "${_msg}"
}

# Show a WARNING message
# $1: message string
_msg_warning() {
    local _msg="${1}"
    printf '[%s] WARNING: %s\n' "${app_name}" "${_msg}" >&2
}

# Show an ERROR message then exit with status
# $1: message string
# $2: exit code number (with 0 does not exit)
_msg_error() {
    local _msg="${1}"
    local _error=${2}
    printf '[%s] ERROR: %s\n' "${app_name}" "${_msg}" >&2
    if (( _error > 0 )); then
        exit "${_error}"
    fi
}

_chroot_init() {
    install -d -m 0755 -o 0 -g 0 -- "${airootfs_dir}"
    _pacman base syslinux
}

_chroot_run() {
    eval -- arch-chroot "${airootfs_dir}" "${run_cmd}"
}

_mount_airootfs() {
    trap "_umount_airootfs" EXIT HUP INT TERM
    install -d -m 0755 -- "${work_dir}/mnt/airootfs"
    _msg_info "Mounting '${airootfs_dir}.img' on '${work_dir}/mnt/airootfs'..."
    mount -- "${airootfs_dir}.img" "${work_dir}/mnt/airootfs"
    _msg_info "Done!"
}

_umount_airootfs() {
    _msg_info "Unmounting '${work_dir}/mnt/airootfs'..."
    umount -d -- "${work_dir}/mnt/airootfs"
    _msg_info "Done!"
    rmdir -- "${work_dir}/mnt/airootfs"
    trap - EXIT HUP INT TERM
}

# Show help usage, with an exit status.
# $1: exit status number.
_usage() {
    IFS='' read -r -d '' usagetext <<ENDUSAGETEXT || true
usage ${app_name} [options] <profile_dir or legacy_command>
  options:
     -A <application> Set an application name for the ISO
                      Default: '${iso_application}'
     -C <file>        pacman configuration file.
                      Default: '${pacman_conf}'
     -D <install_dir> Set an install_dir. All files will by located here.
                      Default: '${install_dir}'
                      NOTE: Max 8 characters, use only [a-z0-9]
     -L <label>       Set the ISO volume label
                      Default: '${iso_label}'
     -P <publisher>   Set the ISO publisher
                      Default: '${iso_publisher}'
     -c <comp_type>   Set SquashFS compression type (gzip, lzma, lzo, xz, zstd)
                      Default: '${sfs_comp}'
     -g <gpg_key>     Set the GPG key to be used for signing the sqashfs image
     -h               This message
     -o <out_dir>     Set the output directory
                      Default: '${out_dir}'
     -p PACKAGE(S)    Package(s) to install, can be used multiple times
     -r <run_cmd>     Set a command to be run in chroot (only relevant for legacy 'run' command)
                      NOTE: Deprecated, will be removed with archiso v49
     -s <sfs_mode>    Set SquashFS image mode (img or sfs)
                      img: prepare airootfs.sfs for dm-snapshot usage
                      sfs: prepare airootfs.sfs for overlayfs usage
                      Default: '${sfs_mode}'
     -v               Enable verbose output
     -w <work_dir>    Set the working directory
                      Default: '${work_dir}'

  profile_dir:        Directory of the archiso profile to build

  legacy_command:     Legacy build.sh command
                      NOTE: Deprecated, will be removed with archiso v49
    init
        initialize a chroot for building
    install
        install packages to the chroot
    run
        run a command in the chroot
    prepare
        cleanup and prepare the airootfs
    pkglist
        create a list of packages installed on the medium
    iso
        create the ISO
ENDUSAGETEXT
    printf '%s' "${usagetext}"
    exit "${1}"
}

# Shows configuration according to command mode.
# $1: build_profile | init | install | run | prepare | iso
_show_config() {
    local _mode="$1"
    _msg_info "${app_name} configuration settings"
    [[ ! -d "${command_name}" ]] && _msg_info "           Legacy Command:   ${command_name}"
    _msg_info "             Architecture:   ${arch}"
    _msg_info "        Working directory:   ${work_dir}"
    _msg_info "   Installation directory:   ${install_dir}"
    case "${_mode}" in
        build_profile)
            _msg_info "         Output directory:   ${out_dir}"
            _msg_info "                  GPG key:   ${gpg_key:-None}"
            _msg_info "                  Profile:   ${profile}"
            _msg_info "Pacman configuration file:   ${pacman_conf}"
            _msg_info "          Image file name:   ${img_name}"
            _msg_info "         ISO volume label:   ${iso_label}"
            _msg_info "            ISO publisher:   ${iso_publisher}"
            _msg_info "          ISO application:   ${iso_application}"
            _msg_info "               Boot modes:   ${bootmodes[*]}"
            _msg_info "                 Packages:   ${pkg_list[*]}"
            ;;
        init)
            _msg_info "Pacman configuration file:   ${pacman_conf}"
            ;;
        install)
            _msg_info "                  GPG key:   ${gpg_key:-None}"
            _msg_info "Pacman configuration file:   ${pacman_conf}"
            _msg_info "                 Packages:   ${pkg_list[*]}"
            ;;
        run)
            _msg_info "              Run command:   ${run_cmd}"
            ;;
        prepare)
            _msg_info "                  GPG key:   ${gpg_key:-None}"
            ;;
        pkglist)
            ;;
        iso)
            _msg_info "         Output directory:   ${out_dir}"
            _msg_info "          Image file name:   ${img_name}"
            _msg_info "         ISO volume label:   ${iso_label}"
            _msg_info "            ISO publisher:   ${iso_publisher}"
            _msg_info "          ISO application:   ${iso_application}"
            ;;
    esac
    [[ "${quiet}" == "y" ]] || printf '\n'
}

# Install desired packages to airootfs
_pacman() {
    _msg_info "Installing packages to '${airootfs_dir}/'..."

    if [[ "${quiet}" = "y" ]]; then
        pacstrap -C "${pacman_conf}" -i -c -G -M -- "${airootfs_dir}" "$@" &> /dev/null
    else
        pacstrap -C "${pacman_conf}" -i -c -G -M -- "${airootfs_dir}" "$@"
    fi

    _msg_info "Done! Packages installed successfully."
}

# Cleanup airootfs
_cleanup() {
    _msg_info "Cleaning up what we can on airootfs..."

    # Delete all files in /boot
    if [[ -d "${airootfs_dir}/boot" ]]; then
        find "${airootfs_dir}/boot" -mindepth 1 -delete
    fi
    # Delete pacman database sync cache files (*.tar.gz)
    if [[ -d "${airootfs_dir}/var/lib/pacman" ]]; then
        find "${airootfs_dir}/var/lib/pacman" -maxdepth 1 -type f -delete
    fi
    # Delete pacman database sync cache
    if [[ -d "${airootfs_dir}/var/lib/pacman/sync" ]]; then
        find "${airootfs_dir}/var/lib/pacman/sync" -delete
    fi
    # Delete pacman package cache
    if [[ -d "${airootfs_dir}/var/cache/pacman/pkg" ]]; then
        find "${airootfs_dir}/var/cache/pacman/pkg" -type f -delete
    fi
    # Delete all log files, keeps empty dirs.
    if [[ -d "${airootfs_dir}/var/log" ]]; then
        find "${airootfs_dir}/var/log" -type f -delete
    fi
    # Delete all temporary files and dirs
    if [[ -d "${airootfs_dir}/var/tmp" ]]; then
        find "${airootfs_dir}/var/tmp" -mindepth 1 -delete
    fi
    # Delete package pacman related files.
    find "${work_dir}" \( -name '*.pacnew' -o -name '*.pacsave' -o -name '*.pacorig' \) -delete
    # Create an empty /etc/machine-id
    printf '' > "${airootfs_dir}/etc/machine-id"

    _msg_info "Done!"
}

# Makes a ext4 filesystem inside a SquashFS from a source directory.
_mkairootfs_img() {
    if [[ ! -e "${airootfs_dir}" ]]; then
        _msg_error "The path '${airootfs_dir}' does not exist" 1
    fi

    _msg_info "Creating ext4 image of 32 GiB..."
    if [[ "${quiet}" == "y" ]]; then
        mkfs.ext4 -q -O '^has_journal,^resize_inode' -E 'lazy_itable_init=0' -m 0 -F -- "${airootfs_dir}.img" 32G
    else
        mkfs.ext4 -O '^has_journal,^resize_inode' -E 'lazy_itable_init=0' -m 0 -F -- "${airootfs_dir}.img" 32G
    fi
    tune2fs -c 0 -i 0 -- "${airootfs_dir}.img" > /dev/null
    _msg_info "Done!"
    _mount_airootfs
    _msg_info "Copying '${airootfs_dir}/' to '${work_dir}/mnt/airootfs/'..."
    cp -aT -- "${airootfs_dir}/" "${work_dir}/mnt/airootfs/"
    chown -- 0:0 "${work_dir}/mnt/airootfs/"
    _msg_info "Done!"
    _umount_airootfs
    install -d -m 0755 -- "${isofs_dir}/${install_dir}/${arch}"
    _msg_info "Creating SquashFS image, this may take some time..."
    if [[ "${quiet}" = "y" ]]; then
        mksquashfs "${airootfs_dir}.img" "${isofs_dir}/${install_dir}/${arch}/airootfs.sfs" -noappend \
            -comp "${sfs_comp}" -no-progress > /dev/null
    else
        mksquashfs "${airootfs_dir}.img" "${isofs_dir}/${install_dir}/${arch}/airootfs.sfs" -noappend \
            -comp "${sfs_comp}"
    fi
    _msg_info "Done!"
    rm -- "${airootfs_dir}.img"
}

# Makes a SquashFS filesystem from a source directory.
_mkairootfs_sfs() {
    if [[ ! -e "${airootfs_dir}" ]]; then
        _msg_error "The path '${airootfs_dir}' does not exist" 1
    fi

    install -d -m 0755 -- "${isofs_dir}/${install_dir}/${arch}"
    _msg_info "Creating SquashFS image, this may take some time..."
    if [[ "${quiet}" = "y" ]]; then
        mksquashfs "${airootfs_dir}" "${isofs_dir}/${install_dir}/${arch}/airootfs.sfs" -noappend \
            -comp "${sfs_comp}" -no-progress > /dev/null
    else
        mksquashfs "${airootfs_dir}" "${isofs_dir}/${install_dir}/${arch}/airootfs.sfs" -noappend \
            -comp "${sfs_comp}"
    fi
    _msg_info "Done!"
}

_mkchecksum() {
    _msg_info "Creating checksum file for self-test..."
    cd -- "${isofs_dir}/${install_dir}/${arch}"
    sha512sum airootfs.sfs > airootfs.sha512
    cd -- "${OLDPWD}"
    _msg_info "Done!"
}

_mksignature() {
    _msg_info "Signing SquashFS image..."
    cd -- "${isofs_dir}/${install_dir}/${arch}"
    gpg --detach-sign --default-key "${gpg_key}" airootfs.sfs
    cd -- "${OLDPWD}"
    _msg_info "Done!"
}

# Helper function to run functions only one time.
_run_once() {
    if [[ ! -e "${work_dir}/build.${1}" ]]; then
        "$1"
        touch "${work_dir}/build.${1}"
    fi
}

# Set up custom pacman.conf with current cache directories.
_make_pacman_conf() {
    local _cache_dirs
    _cache_dirs="$(pacman-conf CacheDir)"
    sed -r "s|^#?\\s*CacheDir.+|CacheDir    = ${_cache_dirs[*]//$'\n'/ }|g" \
        "${pacman_conf}" > "${work_dir}/pacman.conf"
}

# Prepare working directory and copy custom airootfs files (airootfs)
_make_custom_airootfs() {
    local passwd=()

    install -d -m 0755 -o 0 -g 0 -- "${airootfs_dir}"

    if [[ -d "${profile}/airootfs" ]]; then
        _msg_info "Copying custom custom airootfs files and setting up user home directories..."
        cp -af --no-preserve=ownership -- "${profile}/airootfs/." "${airootfs_dir}"

        [[ -e "${airootfs_dir}/etc/shadow" ]] && chmod -f 0400 -- "${airootfs_dir}/etc/shadow"
        [[ -e "${airootfs_dir}/etc/gshadow" ]] && chmod -f 0400 -- "${airootfs_dir}/etc/gshadow"

        # Set up user home directories and permissions
        if [[ -e "${airootfs_dir}/etc/passwd" ]]; then
            while IFS=':' read -a passwd -r; do
                [[ "${passwd[5]}" == '/' ]] && continue
                [[ -z "${passwd[5]}" ]] && continue

                if [[ -d "${airootfs_dir}${passwd[5]}" ]]; then
                    chown -hR -- "${passwd[2]}:${passwd[3]}" "${airootfs_dir}${passwd[5]}"
                    chmod -f 0750 -- "${airootfs_dir}${passwd[5]}"
                else
                    install -d -m 0750 -o "${passwd[2]}" -g "${passwd[3]}" -- "${airootfs_dir}${passwd[5]}"
                fi
             done < "${airootfs_dir}/etc/passwd"
        fi
        _msg_info "Done!"
    fi
}

# Packages (airootfs)
_make_packages() {
    if [[ -n "${gpg_key}" ]]; then
        exec {ARCHISO_GNUPG_FD}<>"${work_dir}/pubkey.gpg"
        export ARCHISO_GNUPG_FD
    fi
    _pacman "${pkg_list[@]}"
    if [[ -n "${gpg_key}" ]]; then
        exec {ARCHISO_GNUPG_FD}<&-
        unset ARCHISO_GNUPG_FD
    fi
}

# Customize installation (airootfs)
_make_customize_airootfs() {
    local passwd=()

    if [[ -e "${profile}/airootfs/etc/passwd" ]]; then
        _msg_info "Copying /etc/skel/* to user homes..."
        while IFS=':' read -a passwd -r; do
            (( passwd[2] >= 1000 && passwd[2] < 60000 )) || continue
            [[ "${passwd[5]}" == '/' ]] && continue
            [[ -z "${passwd[5]}" ]] && continue
            cp -dnRT --preserve=mode,timestamps,links -- "${airootfs_dir}/etc/skel" "${airootfs_dir}${passwd[5]}"
            chmod -f 0750 -- "${airootfs_dir}${passwd[5]}"
            chown -hR -- "${passwd[2]}:${passwd[3]}" "${airootfs_dir}${passwd[5]}"

        done < "${profile}/airootfs/etc/passwd"
        _msg_info "Done!"
    fi

    if [[ -e "${airootfs_dir}/root/customize_airootfs.sh" ]]; then
        _msg_info "Running customize_airootfs.sh in '${airootfs_dir}' chroot..."
        _msg_warning "customize_airootfs.sh is deprecated! Support for it will be removed in a future archiso version."
        local run_cmd="/root/customize_airootfs.sh"
        _chroot_run
        rm -- "${airootfs_dir}/root/customize_airootfs.sh"
        _msg_info "Done! customize_airootfs.sh run successfully."
    fi
}

# Set up boot loaders
_make_bootmodes() {
    local bootmode
    for bootmode in "${bootmodes[@]}"; do
        if typeset -f "_make_boot_${bootmode}" &> /dev/null; then
            _run_once "_make_boot_${bootmode}"
        else
            _msg_error "${bootmode} is not a valid boot mode" 1
        fi
    done
}

# Prepare kernel/initramfs ${install_dir}/boot/
_make_boot_on_iso() {
    local ucode_image
    _msg_info "Preparing kernel and intramfs for the ISO 9660 file system..."
    install -d -m 0755 -- "${isofs_dir}/${install_dir}/boot/${arch}"
    install -m 0644 -- "${airootfs_dir}/boot/initramfs-"*".img" "${isofs_dir}/${install_dir}/boot/${arch}/"
    install -m 0644 -- "${airootfs_dir}/boot/vmlinuz-"* "${isofs_dir}/${install_dir}/boot/${arch}/"

    for ucode_image in {intel-uc.img,intel-ucode.img,amd-uc.img,amd-ucode.img,early_ucode.cpio,microcode.cpio}; do
        if [[ -e "${airootfs_dir}/boot/${ucode_image}" ]]; then
            install -m 0644 -- "${airootfs_dir}/boot/${ucode_image}" "${isofs_dir}/${install_dir}/boot/"
            if [[ -e "${airootfs_dir}/usr/share/licenses/${ucode_image%.*}/" ]]; then
                install -d -m 0755 -- "${isofs_dir}/${install_dir}/boot/licenses/${ucode_image%.*}/"
                install -m 0644 -- "${airootfs_dir}/usr/share/licenses/${ucode_image%.*}/"* \
                    "${isofs_dir}/${install_dir}/boot/licenses/${ucode_image%.*}/"
            fi
        fi
    done
    _msg_info "Done!"
}

# Prepare /${install_dir}/boot/syslinux
_make_boot_bios.syslinux.mbr() {
    _msg_info "Setting up SYSLINUX for BIOS booting from a disk..."
    install -d -m 0755 -- "${isofs_dir}/${install_dir}/boot/syslinux"
    for _cfg in "${profile}/syslinux/"*.cfg; do
        sed "s|%ARCHISO_LABEL%|${iso_label}|g;
             s|%INSTALL_DIR%|${install_dir}|g;
             s|%ARCH%|${arch}|g" \
             "${_cfg}" > "${isofs_dir}/${install_dir}/boot/syslinux/${_cfg##*/}"
    done
    if [[ -e "${profile}/syslinux/splash.png" ]]; then
        install -m 0644 -- "${profile}/syslinux/splash.png" "${isofs_dir}/${install_dir}/boot/syslinux/"
    fi
    install -m 0644 -- "${airootfs_dir}/usr/lib/syslinux/bios/"*.c32 "${isofs_dir}/${install_dir}/boot/syslinux/"
    install -m 0644 -- "${airootfs_dir}/usr/lib/syslinux/bios/lpxelinux.0" "${isofs_dir}/${install_dir}/boot/syslinux/"
    install -m 0644 -- "${airootfs_dir}/usr/lib/syslinux/bios/memdisk" "${isofs_dir}/${install_dir}/boot/syslinux/"

    _run_once _make_boot_on_iso

    if [[ -e "${isofs_dir}/${install_dir}/boot/syslinux/hdt.c32" ]]; then
        install -d -m 0755 -- "${isofs_dir}/${install_dir}/boot/syslinux/hdt"
        if [[ -e "${airootfs_dir}/usr/share/hwdata/pci.ids" ]]; then
            gzip -c -9 "${airootfs_dir}/usr/share/hwdata/pci.ids" > \
                "${isofs_dir}/${install_dir}/boot/syslinux/hdt/pciids.gz"
        fi
        find "${airootfs_dir}/usr/lib/modules" -name 'modules.alias' -print -exec gzip -c -9 '{}' ';' -quit > \
            "${isofs_dir}/${install_dir}/boot/syslinux/hdt/modalias.gz"
    fi

    # Add other aditional/extra files to ${install_dir}/boot/
    if [[ -e "${airootfs_dir}/boot/memtest86+/memtest.bin" ]]; then
        # rename for PXE: https://wiki.archlinux.org/index.php/Syslinux#Using_memtest
        install -m 0644 -- "${airootfs_dir}/boot/memtest86+/memtest.bin" "${isofs_dir}/${install_dir}/boot/memtest"
        install -d -m 0755 -- "${isofs_dir}/${install_dir}/boot/licenses/memtest86+/"
        install -m 0644 -- "${airootfs_dir}/usr/share/licenses/common/GPL2/license.txt" \
            "${isofs_dir}/${install_dir}/boot/licenses/memtest86+/"
    fi
    _msg_info "Done! SYSLINUX set up for BIOS booting from a disk successfully."
}

# Prepare /isolinux
_make_boot_bios.syslinux.eltorito() {
    _msg_info "Setting up SYSLINUX for BIOS booting from an optical disc..."
    install -d -m 0755 -- "${isofs_dir}/isolinux"
    for _cfg in "${profile}/isolinux/"*".cfg"; do
        sed "s|%ARCHISO_LABEL%|${iso_label}|g;
             s|%INSTALL_DIR%|${install_dir}|g;
             s|%ARCH%|${arch}|g" \
             "${_cfg}" > "${isofs_dir}/isolinux/${_cfg##*/}"
    done
    install -m 0644 -- "${airootfs_dir}/usr/lib/syslinux/bios/isolinux.bin" "${isofs_dir}/isolinux/"
    install -m 0644 -- "${airootfs_dir}/usr/lib/syslinux/bios/isohdpfx.bin" "${isofs_dir}/isolinux/"
    install -m 0644 -- "${airootfs_dir}/usr/lib/syslinux/bios/ldlinux.c32" "${isofs_dir}/isolinux/"

    # isolinux.cfg loads syslinux.cfg
    _run_once _make_boot_bios.syslinux.mbr

    _msg_info "Done! SYSLINUX set up for BIOS booting from an optical disc successfully."
}

# Prepare /EFI on ISO-9660
_make_efi() {
    _msg_info "Preparing an /EFI directory for the ISO 9660 file system..."
    install -d -m 0755 -- "${isofs_dir}/EFI/BOOT"
    install -m 0644 -- "${airootfs_dir}/usr/lib/systemd/boot/efi/systemd-bootx64.efi" \
        "${isofs_dir}/EFI/BOOT/BOOTx64.EFI"

    install -d -m 0755 -- "${isofs_dir}/loader/entries"
    install -m 0644 -- "${profile}/efiboot/loader/loader.conf" "${isofs_dir}/loader/"

    for _conf in "${profile}/efiboot/loader/entries/"*".conf"; do
        sed "s|%ARCHISO_LABEL%|${iso_label}|g;
             s|%INSTALL_DIR%|${install_dir}|g;
             s|%ARCH%|${arch}|g" \
            "${_conf}" > "${isofs_dir}/loader/entries/${_conf##*/}"
    done

    # edk2-shell based UEFI shell
    # shellx64.efi is picked up automatically when on /
    if [[ -e "${airootfs_dir}/usr/share/edk2-shell/x64/Shell_Full.efi" ]]; then
        install -m 0644 -- "${airootfs_dir}/usr/share/edk2-shell/x64/Shell_Full.efi" "${isofs_dir}/shellx64.efi"
    fi
    _msg_info "Done!"
}

# Prepare kernel/initramfs on efiboot.img
_make_boot_on_fat() {
    local ucode_image all_ucode_images=()
    _msg_info "Preparing kernel and intramfs for the FAT file system..."
    mmd -i "${isofs_dir}/EFI/archiso/efiboot.img" \
        "::/${install_dir}" "::/${install_dir}/boot" "::/${install_dir}/boot/${arch}"
    mcopy -i "${isofs_dir}/EFI/archiso/efiboot.img" "${airootfs_dir}/boot/vmlinuz-"* \
        "${airootfs_dir}/boot/initramfs-"*".img" "::/${install_dir}/boot/${arch}/"
    for ucode_image in \
        "${airootfs_dir}/boot/"{intel-uc.img,intel-ucode.img,amd-uc.img,amd-ucode.img,early_ucode.cpio,microcode.cpio}
    do
        if [[ -e "${ucode_image}" ]]; then
            all_ucode_images+=("${ucode_image}")
        fi
    done
    if (( ${#all_ucode_images[@]} )); then
        mcopy -i "${isofs_dir}/EFI/archiso/efiboot.img" "${all_ucode_images[@]}" "::/${install_dir}/boot/"
    fi
    _msg_info "Done!"
}

# Prepare efiboot.img::/EFI for EFI boot mode
_make_boot_uefi-x64.systemd-boot.esp() {
    local efiboot_imgsize="0"
    _msg_info "Setting up systemd-boot for UEFI booting..."
    install -d -m 0755 -- "${isofs_dir}/EFI/archiso"

    # the required image size in KiB (rounded up to the next full MiB with an additional MiB for reserved sectors)
    efiboot_imgsize="$(du -bc \
        "${airootfs_dir}/usr/lib/systemd/boot/efi/systemd-bootx64.efi" \
        "${airootfs_dir}/usr/share/edk2-shell/x64/Shell_Full.efi" \
        "${profile}/efiboot/" \
        "${airootfs_dir}/boot/vmlinuz-"* \
        "${airootfs_dir}/boot/initramfs-"*".img" \
        "${airootfs_dir}/boot/"{intel-uc.img,intel-ucode.img,amd-uc.img,amd-ucode.img,early_ucode.cpio,microcode.cpio} \
        2>/dev/null | awk 'function ceil(x){return int(x)+(x>int(x))}
            function byte_to_kib(x){return x/1024}
            function mib_to_kib(x){return x*1024}
            END {print mib_to_kib(ceil((byte_to_kib($1)+1024)/1024))}'
        )"
    # The FAT image must be created with mkfs.fat not mformat, as some systems have issues with mformat made images:
    # https://lists.gnu.org/archive/html/grub-devel/2019-04/msg00099.html
    _msg_info "Creating FAT image of size: ${efiboot_imgsize} KiB..."
    mkfs.fat -C -n ARCHISO_EFI "${isofs_dir}/EFI/archiso/efiboot.img" "$efiboot_imgsize"

    mmd -i "${isofs_dir}/EFI/archiso/efiboot.img" ::/EFI ::/EFI/BOOT
    mcopy -i "${isofs_dir}/EFI/archiso/efiboot.img" \
        "${airootfs_dir}/usr/lib/systemd/boot/efi/systemd-bootx64.efi" ::/EFI/BOOT/BOOTx64.EFI

    mmd -i "${isofs_dir}/EFI/archiso/efiboot.img" ::/loader ::/loader/entries
    mcopy -i "${isofs_dir}/EFI/archiso/efiboot.img" "${profile}/efiboot/loader/loader.conf" ::/loader/
    for _conf in "${profile}/efiboot/loader/entries/"*".conf"; do
        sed "s|%ARCHISO_LABEL%|${iso_label}|g;
             s|%INSTALL_DIR%|${install_dir}|g;
             s|%ARCH%|${arch}|g" \
            "${_conf}" | mcopy -i "${isofs_dir}/EFI/archiso/efiboot.img" - "::/loader/entries/${_conf##*/}"
    done

    # shellx64.efi is picked up automatically when on /
    if [[ -e "${airootfs_dir}/usr/share/edk2-shell/x64/Shell_Full.efi" ]]; then
        mcopy -i "${isofs_dir}/EFI/archiso/efiboot.img" \
            "${airootfs_dir}/usr/share/edk2-shell/x64/Shell_Full.efi" ::/shellx64.efi
    fi

    # Copy kernel and initramfs
    _run_once _make_boot_on_fat

    _msg_info "Done! systemd-boot set up for UEFI booting successfully."
}

# Prepare efiboot.img::/EFI for "El Torito" EFI boot mode
_make_boot_uefi-x64.systemd-boot.eltorito() {
    _run_once _make_boot_uefi-x64.systemd-boot.esp
    # Set up /EFI on ISO-9660
    _run_once _make_efi
}

# Build airootfs filesystem image
_make_prepare() {
    if [[ "${sfs_mode}" == "sfs" ]]; then
        _mkairootfs_sfs
    else
        _mkairootfs_img
    fi
    _mkchecksum
    if [[ "${gpg_key}" ]]; then
      _mksignature
    fi
}

# Build ISO
_make_iso() {
    local xorrisofs_options=()

    [[ -d "${out_dir}" ]] || install -d -- "${out_dir}"

    if [[ "${quiet}" == "y" ]]; then
        xorrisofs_options+=('-quiet')
    fi
    # shellcheck disable=SC2076
    if [[ " ${bootmodes[*]} " =~ ' bios.syslinux.' ]]; then
        if [[ ! -f "${isofs_dir}/isolinux/isolinux.bin" ]]; then
            _msg_error "The file '${isofs_dir}/isolinux/isolinux.bin' does not exist." 1
        fi
        if [[ ! -f "${isofs_dir}/isolinux/isohdpfx.bin" ]]; then
            _msg_error "The file '${isofs_dir}/isolinux/isohdpfx.bin' does not exist." 1
        fi
        xorrisofs_options+=(
            '-eltorito-boot' 'isolinux/isolinux.bin'
            '-eltorito-catalog' 'isolinux/boot.cat'
            '-no-emul-boot' '-boot-load-size' '4' '-boot-info-table'
            '-isohybrid-mbr' "${isofs_dir}/isolinux/isohdpfx.bin"
        )
    fi
    # shellcheck disable=SC2076
    if [[ " ${bootmodes[*]} " =~ ' uefi-x64.systemd-boot.' ]]; then
        xorrisofs_options+=(
            '-eltorito-alt-boot'
            '-e' 'EFI/archiso/efiboot.img'
            '-no-emul-boot'
            '-isohybrid-gpt-basdat'
        )
    fi

    _msg_info "Creating ISO image..."
    xorriso -as mkisofs \
            -iso-level 3 \
            -full-iso9660-filenames \
            -joliet \
            -joliet-long \
            -rational-rock \
            -volid "${iso_label}" \
            -appid "${iso_application}" \
            -publisher "${iso_publisher}" \
            -preparer "prepared by ${app_name}" \
            "${xorrisofs_options[@]}" \
            -output "${out_dir}/${img_name}" \
            "${isofs_dir}/"
    _msg_info "Done!"
    du -h -- "${out_dir}/${img_name}"
}

# Read profile's values from profiledef.sh
_read_profile() {
    if [[ -z "${profile}" ]]; then
        _msg_error "No profile specified!" 1
    fi
    if [[ ! -d "${profile}" ]]; then
        _msg_error "Profile '${profile}' does not exist!" 1
    elif [[ ! -e "${profile}/profiledef.sh" ]]; then
        _msg_error "Profile '${profile}' is missing 'profiledef.sh'!" 1
    else
        cd -- "${profile}"

        # Source profile's variables
        # shellcheck source=configs/releng/profiledef.sh
        . "${profile}/profiledef.sh"

        # Resolve paths
        packages="$(realpath -- "${profile}/packages.${arch}")"
        pacman_conf="$(realpath -- "${pacman_conf}")"

        # Enumerate packages
        [[ -e "${packages}" ]] || _msg_error "File '${packages}' does not exist!" 1
        mapfile -t pkg_list < <(sed '/^[[:blank:]]*#.*/d;s/#.*//;/^[[:blank:]]*$/d' "${packages}")

        cd -- "${OLDPWD}"
    fi
}

# set overrides from mkarchiso option parameters, if present
_set_overrides() {
    if [[ -n "$override_iso_label" ]]; then
        iso_label="$override_iso_label"
    fi
    if [[ -n "$override_iso_publisher" ]]; then
        iso_publisher="$override_iso_publisher"
    fi
    if [[ -n "$override_iso_application" ]]; then
        iso_application="$override_iso_application"
    fi
    if [[ -n "$override_install_dir" ]]; then
        install_dir="$override_install_dir"
    fi
    if [[ -n "$override_pacman_conf" ]]; then
        pacman_conf="$override_pacman_conf"
    fi
    if [[ -n "$override_gpg_key" ]]; then
        gpg_key="$override_gpg_key"
    fi
}


_export_gpg_publickey() {
    if [[ -n "${gpg_key}" ]]; then
        gpg --batch --output "${work_dir}/pubkey.gpg" --export "${gpg_key}"
    fi
}


_make_pkglist() {
    install -d -m 0755 -- "${isofs_dir}/${install_dir}"
    _msg_info "Creating a list of installed packages on live-enviroment..."
    pacman -Q --sysroot "${airootfs_dir}" > "${isofs_dir}/${install_dir}/pkglist.${arch}.txt"
    _msg_info "Done!"
}

command_pkglist() {
    _show_config "${FUNCNAME[0]#command_}"
    _make_pkglist
}

# Create an ISO9660 filesystem from "iso" directory.
command_iso() {
    bootmodes=('bios.syslinux.mbr' 'bios.syslinux.eltorito')

    # If exists, add an EFI "El Torito" boot image (FAT filesystem) to ISO-9660 image.
    if [[ -f "${isofs_dir}/EFI/archiso/efiboot.img" ]]; then
        bootmodes+=('uefi-x64.systemd-boot.esp' 'uefi-x64.systemd-boot.eltorito')
    fi

    _show_config "${FUNCNAME[0]#command_}"
    _make_iso
}

# create airootfs.sfs filesystem, and push it in "iso" directory.
command_prepare() {
    _show_config "${FUNCNAME[0]#command_}"

    _cleanup
    _make_prepare
}

# Install packages on airootfs.
# A basic check to avoid double execution/reinstallation is done via hashing package names.
command_install() {
    if [[ ! -f "${pacman_conf}" ]]; then
        _msg_error "Pacman config file '${pacman_conf}' does not exist" 1
    fi

    if (( ${#pkg_list[@]} == 0 )); then
        _msg_error "Packages must be specified" 0
        _usage 1
    fi

    _show_config "${FUNCNAME[0]#command_}"

    _make_packages
}

command_init() {
    _show_config "${FUNCNAME[0]#command_}"
    _chroot_init
}

command_run() {
    _show_config "${FUNCNAME[0]#command_}"
    _chroot_run
}

command_build_profile() {
    # Set up essential directory paths
    airootfs_dir="${work_dir}/${arch}/airootfs"
    isofs_dir="${work_dir}/iso"
    # Set ISO file name
    img_name="${iso_name}-${iso_version}-${arch}.iso"

    _show_config "${FUNCNAME[0]#command_}"

    # Create working directory
    [[ -d "${work_dir}" ]] || install -d -- "${work_dir}"

    _run_once _make_pacman_conf
    _run_once _export_gpg_publickey
    _run_once _make_custom_airootfs
    _run_once _make_packages
    _run_once _make_customize_airootfs
    _run_once _make_pkglist
    _make_bootmodes
    _run_once _cleanup
    _run_once _make_prepare
    _run_once _make_iso
}

while getopts 'p:r:C:L:P:A:D:w:o:s:c:g:vh?' arg; do
    case "${arg}" in
        p)
            read -r -a opt_pkg_list <<< "${OPTARG}"
            pkg_list+=("${opt_pkg_list[@]}")
            ;;
        r) run_cmd="${OPTARG}" ;;
        C) override_pacman_conf="$(realpath -- "${OPTARG}")" ;;
        L) override_iso_label="${OPTARG}" ;;
        P) override_iso_publisher="${OPTARG}" ;;
        A) override_iso_application="${OPTARG}" ;;
        D) override_install_dir="${OPTARG}" ;;
        w) work_dir="$(realpath -- "${OPTARG}")" ;;
        o) out_dir="$(realpath -- "${OPTARG}")" ;;
        s) sfs_mode="${OPTARG}" ;;
        c) sfs_comp="${OPTARG}" ;;
        g) override_gpg_key="${OPTARG}" ;;
        v) quiet="n" ;;
        h|?) _usage 0 ;;
        *)
            _msg_error "Invalid argument '${arg}'" 0
            _usage 1
            ;;
    esac
done

if (( EUID != 0 )); then
    _msg_error "${app_name} must be run as root." 1
fi

shift $((OPTIND - 1))

if (( $# < 1 )); then
    _msg_error "No command specified" 0
    _usage 1
fi
command_name="${1}"

# Set directory path defaults for legacy commands
airootfs_dir="${work_dir}/airootfs"
isofs_dir="${work_dir}/iso"

case "${command_name}" in
    init)
        _msg_warning "The '${command_name}' command is deprecated! It will be removed with archiso v49."
        _set_overrides
        command_init
        ;;
    install)
        _msg_warning "The '${command_name}' command is deprecated! It will be removed with archiso v49."
        _set_overrides
        command_install
        ;;
    run)
        _msg_warning "The '${command_name}' command is deprecated! It will be removed with archiso v49."
        command_run
        ;;
    prepare)
        _msg_warning "The '${command_name}' command is deprecated! It will be removed with archiso v49."
        _set_overrides
        command_prepare
        ;;
    pkglist)
        _msg_warning "The '${command_name}' command is deprecated! It will be removed with archiso v49."
        command_pkglist
        ;;
    iso)
        _msg_warning "The '${command_name}' command is deprecated! It will be removed with archiso v49."
        if (( $# < 2 )); then
            _msg_error "No image specified" 0
            _usage 1
        fi
        img_name="${2}"
        _set_overrides
        command_iso
        ;;
    *)
        # NOTE: we call read_profile here, assuming that the first non-option parameter is a profile directory
        # This way we can retain backwards compatibility with legacy build.sh scripts until we deprecate the old way of
        # calling mkarchiso with named parameters in v49
        profile="$(realpath -- "${command_name}")"
        _read_profile
        _set_overrides
        command_build_profile
        ;;
esac

# vim:ts=4:sw=4:et:
