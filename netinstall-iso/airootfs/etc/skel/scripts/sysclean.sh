#!/bin/sh

pacman -Rscn $(pacman -Qtdq)
pkgfile -u
updatedb
pacman-db-upgrade
yes | pacman -Scc
sync
