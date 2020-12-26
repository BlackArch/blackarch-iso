#!/bin/sh

pacman -Rscn $(yay -Qtdq)
updatedb
pkgfile -u
pacman -Fyy
pacman-db-upgrade
yes | pacman -Scc
sync
