#!/bin/sh

if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/?*.sh; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

session=${1:-xfce}

case $session in
  i3|i3wm    ) exec i3 ;;
  kde        ) exec startplasma-x11 ;;
  xfce|xfce4 ) exec startxfce4 ;;
  *          ) exec "$@" ;;
esac
