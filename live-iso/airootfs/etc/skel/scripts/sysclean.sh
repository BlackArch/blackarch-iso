#!/bin/sh

pacman -Rscn $(pacman -Qtdq)
pacman -Fyy
pkgfile -u
updatedb
pacman-db-upgrade
yes | pacman -Scc
sync
