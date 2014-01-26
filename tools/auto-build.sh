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
    echo "usage: ./auto-build.sh <packages_path> <arch>"
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
        echo "unknown arch!"
        exit 1337
    fi
fi

cp -r "../live-iso" "../live-iso-${arch}"

#cd "menu-maker"
#sh menu-maker.sh "${pkgpath}"
