#!/bin/sh
# Regenerate the BlackArch menu after a pacman transaction.
#
# Always exits 0. A menu that failed to regenerate is a cosmetic problem; a
# non-zero post-transaction hook during the ISO build's pacstrap would abort a
# multi-hour build over one, and in the live session it would make every
# `pacman -S` look like it failed.

python3 /usr/share/blackarch-menu/BlackArchXfceMenuTool.py --system --nested ||
  echo "warning: BlackArch menu regeneration failed" >&2

exit 0
