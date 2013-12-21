#!/bin/sh
#
# ~/.xinitrc
#
# Executed by startx (run your window manager from here)

if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

exec $1

run_dwm(){
  xsetroot -solid black &
  xcompmgr -c -f -D 5 &
  xautolock -time 10 -locker slock
  exec dwm
}

run_spectrmw(){
  xsetroot -solid black &
  xcompmgr -c -f -D 5 &
  xautolock -time 10 -locker slock
  exec spectrmw
}

run_awesome(){
  xautolock -time 10 -locker slock
  exec awesome
}

run_ratpoison(){
  # the black/white grid as background doesn't suit my taste.
  xsetroot -solid black &
  # ratpoison is compatible with xcompmgr! now you can have real transparency
  xcompmgr -c -f -D 5 &
  #fire up ratpoison!
  exec ratpoison
}

run_openbox(){
  exec openbox-session
}

#exec gnome-session
# exec startkde
# exec startxfce4
# ...or the Window Manager of your choice
