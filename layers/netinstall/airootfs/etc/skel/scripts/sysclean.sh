#!/bin/sh

pacman -Qtdq | xargs -r pacman -Rscn
updatedb
pkgfile -u
pacman -Fyy
pacman-db-upgrade
yes | pacman -Scc
sync
