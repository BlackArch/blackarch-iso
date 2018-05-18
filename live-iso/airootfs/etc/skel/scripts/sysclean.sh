#!/bin/sh

pacman -Rscn $(pacman -Qtdq)
pkgfile -u
pacman-optimize
updatedb
pacman-db-upgrade
yes | pacman -Scc
sync
