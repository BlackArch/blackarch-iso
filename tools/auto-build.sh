#!/bin/sh
#
# auto builds blackarch ISO of given architecture
#

if [ "`pwd | awk -F'/' '{print $(NF-1)"-"$(NF)}'`" != "blackarch-iso-tools" ]
then
    echo "please run from blackarch-iso/tools/ directory"
    exit 1337
fi

if [ ${#} -ne 2 ]
then
    echo "usage: ./auto-build.sh <packages-path> <arch>"
    echo "arch: i686 x86_64"

    exit 1337
else
    pkgpath="${1}"
    arch="${2}"

    if [ ! -d "${pkgpath}/ripdc" ]
    then
        echo "wrong packages directory!"
        exit 1337
    fi

    if [ "${arch}" != "i686" -a "${arch}" != "x86_64" ]
    then
        echo "[ERROR] unknown arch!"
        exit 1337
    fi
fi

if [ `whoami` != "root" ]
then
    echo "[ERROR] you need to be r00t"
    exit 1337
fi

if [ -d "../live-iso-${arch}" ]
then
    echo "[WARNING] live-iso-${arch} exists..."
else
    cp -r "../live-iso" "../live-iso-${arch}"
fi

sh menu-maker/menu-maker.sh "${pkgpath}"

mv menu-maker/fluxbox-menu \
    "../live-iso-${arch}/root-image/usr/share/fluxbox/menu"
mv menu-maker/openbox-menu \
    "../live-iso-${arch}/root-image/etc/xdg/openbox/menu.xml"
mv menu-maker/awesome-menu \
    "../live-iso-${arch}/root-image/etc/xdg/awesome/rc.lua"

#sh package-list/package-list.sh "${pkgpath}"
#mv package-list/packages.x86_64 package-list/packages.i686 \
#    "../live-iso-${arch}/"

cp "abuild.sh" "../live-iso-${arch}"

cd "../live-iso-${arch}" && chown -R root:root * && sh abuild.sh -a ${arch}
