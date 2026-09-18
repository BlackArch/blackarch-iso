# Overview

This is the README file providing basic info on where you can find things as well as provide helpful links for further information on the contents of this repository.

## All ISOs

* Full ISO
  * The largest of the ISOs and installs *all* tools
* NetInstall ISO
  * The smallest ISO and allows you to selectively install tools
* Slim ISO
  * The newest ISO, by default is configured with XFCE4 and LightDM

## How the ISO is built

The ISO is built with the archiso tool that can be downloaded from the official arch repositories.

## Repository layout: layers instead of copied profiles

The three ISOs share most of their configuration, so instead of keeping three full copies of an archiso profile the repo stores **layers**. Each variant is assembled at build time by stacking layers on top of each other:

```
layers/
 |- base/         shared by ALL variants (pacman keyring setup, mirror
 |                selection, syslinux theme, .bashrc, core packages, ...)
 |- graphical/    shared by the graphical live ISOs (full + slim)
 |- full/         only what is specific to the Full ISO
 |- slim/         only what is specific to the Slim ISO
 \- netinstall/   only what is specific to the NetInstall ISO

full       = base + graphical + full
slim       = base + graphical + slim
netinstall = base + netinstall
```

Rules:

* Layers are copied in order, and a file in a later layer **replaces** the same path from an earlier one. To change a shared file for one variant only, put your version at the same path in that variant's layer.
* `packages.x86_64` is **not** replaced: the lists from all layers are concatenated. Each layer lists only the packages it adds. A package that appears in two layers triggers a warning.
* Put a file in `base/` (or `graphical/`) only when it is really meant to be identical everywhere; otherwise keep it in the variant layer.
* Files ending in `.in` are **templates** (they live in `base/`): `profiledef.sh`, the systemd-boot entries, the syslinux menus and `/etc/dev-rel`. Their `@PLACEHOLDERS@` are filled from the variant's `layers/<variant>/variant.conf` (`VARIANT_ID`, `VARIANT_NAME`, `ISO_NAME`, `VARIANT_PURPOSE`, `FILE_PERMISSIONS`). To change a boot menu, edit the template once and all three ISOs get it. A variant can still ship the plain file (without `.in`) to override a template completely. An unknown placeholder stops the build.
* Do not commit `airootfs/etc/pacman.d/gnupg/`: the live system mounts a tmpfs there and `pacman-init.service` generates a fresh keyring at boot.
* Only add a config file to `airootfs` if it changes a setting. Prefer drop-ins (e.g. `etc/systemd/journald.conf.d/volatile-storage.conf`) over full copies of a package's default config.
* The layer order per variant lives in `tools/merge-profile.sh`  (`VARIANT_LAYERS`). Adding a new variant = new `layers/<name>/` with a
`variant.conf` + one line in that table.

To see the complete profile for a variant without building an ISO:

```
./tools/merge-profile.sh --list
./tools/merge-profile.sh slim /tmp/slim-profile
```

`tools/build-iso.sh --class <variant>` does this automatically before calling
`mkarchiso`.

## File structure of an (assembled) archiso profile
```
Profile
 |- airootfs/
 |- efiboot/
 |- syslinux/
 |- packages.ARCH
 |- pacman.conf
 \- profiledef.sh

ARCH = x86_64
```

#### packages.ARCH

All files must be listed one per line. lines that are blank are ignored and so are lines commented out with `#` the packages **mkinitcpio** and **mkinitcpio-archiso** are mandatory see [issue #30](https://gitlab.archlinux.org/archlinux/archiso/-/issues/30)

#### pacman.conf

A configuration for pacman is required per profile. Some configuration options will not be used or will be modified:

* CacheDir: the profile's option is only used if it is not the default (i.e. /var/cache/pacman/pkg) and if it is not the same as the system's option. In all other cases the system's pacman cache is used.

* HookDir: it is always set to the /etc/pacman.d/hooks directory in the work directory's airootfs to allow modification via the profile and ensure interoparability with hosts using dracut ([see #73](https://gitlab.archlinux.org/archlinux/archiso/-/issues/73))

* RootDir: it is always removed, as setting it explicitely otherwise refers to the host's root filesystem (see man 8 pacman for further information on the -r option used by pacstrap)

* LogFile: it is always removed, as setting it explicitely otherwise refers to the host's pacman log file (see man 8 pacman for further information on the -r option used by pacstrap)

* DBPath: it is always removed, as setting it explicitely otherwise refers to the host's pacman database (see man 8 pacman for further information on the -r option used by pacstrap)

#### airootfs directory

This is the directory that holdes any files that will be put into the `/etc` directory, as such you can add or modifty files by placing them inside the corresponding directory.

###### example

```
|- airootfs
\- etc
  \- hosts
```

Any files will by default have the the 644 permissions and directories will have the 755 permissions. this can be changed in `profiledef.sh`.

With this overlay structure it is possible to e.g. create users and set passwords for them, by providing airootfs/etc/passwd, airootfs/etc/shadow, airootfs/etc/gshadow (see man 5 passwd, man 5 shadow and man 5 gshadow respectively).

If user home directories exist in the profile's airootfs, their ownership and (and top-level) permissions will be altered according to the provided information in the password file.

#### Bootloader configuration

The profile may contain several boot loaders. They are explained in the following subsetions.

###### efiboot directory

This directory is mandatory when the uefi-x64.systemd-boot.esp or uefi-x64.systemd-boot.eltorito bootmodes are selected in profiledef.sh. It contains configuration for
[systemd-boot](https://www.freedesktop.org/wiki/Software/systemd/systemd-boot/).

The custom template identifiers are only understood in the boot loader entry `.conf` files *(i.e. not in loader.conf).*

###### syslinux direcotry

This directory is mandatory when the bios.syslinux.mbr or the bios.syslinux.eltorito bootmodes are selected in profiledef.sh. It contains configuration files for syslinux or isolinux , or pxelinux used in the resuling image. The custom template identifiers are understood in all `.cfg` files in this directory.


# BlackArch Specific info

This section is for finding info specific to the BlackArch ISO repos.

## Tools/Misc Info

## Tools directory

This directory contains a compilation of tools used by some of the devs for working with the ISO.

## misc directory

Contains certain files for development as well as a list of disabled tools. Plus the upstream packages.

## etc directory

This contains basic info that will be placed in the `/etc` directory. it contains the preconfigured hosts file, hostname file as well as systemd configurations, lightdm configurations, and will also hold xfce4 configurations and calamares configurations when they are installed. the configurations are located in the corresponding repositories which will be linked now. there will be more repositories linked that come in the NetInstall ISO and the Full ISO.

   - [xfce config](https://github.com/BlackArch/blackarch-config-xfce)
   - [calamares](https://github.com/BlackArch/blackarch-config-calamares)
   - [X11/Xorg](https://github.com/BlackArch/blackarch-config-x11)
   - [zsh](https://github.com/BlackArch/blackarch-config-zsh)
   - [vim](https://github.com/BlackArch/blackarch-config-vim)
   - [openbox](https://github.com/BlackArch/blackarch-config-openbox)
   - [fluxbox](https://github.com/BlackArch/blackarch-config-fluxbox)
   - [awesomewm](https://github.com/BlackArch/blackarch-config-awesome)
   - [spectrwm](https://github.com/BlackArch/blackarch-config-spectrwm)
   - [LXDM](https://github.com/BlackArch/blackarch-config-lxdm)
   - [i3](https://github.com/BlackArch/blackarch-config-i3)
   - [gtk](https://github.com/BlackArch/blackarch-config-gtk)

## root directory

This holds some scripts for configuring the build and should not be modfied unless you have knowledge of how the `archiso` tool works.

## /usr/share directory

This holds the backgrounds and icons for the various builds of the ISOs.

# Further info

Further info can be found within the files themselves which will be commented and documented properly as time goes on.