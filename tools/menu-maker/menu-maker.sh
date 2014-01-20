#!/bin/sh
#
# generates menus for fluxbox, openbox and awesome wms.


_GROUPS="`pacman -Sg | grep blackarch- |
grep -vE '\<analysis\>|\<web\>|\<forensics\>|\<intel\>' | sort -u |
tr -s '\n' ' '`"


if [ ${#} -ne 1 ]
then
    echo "${0} <packages_path>"
    exit 1337
fi

make_fluxbox()
{
    cat fluxbox-header.tmpl > fluxbox-menu
    echo "      [submenu] (${grp})" >> fluxbox-menu
    echo "          [exec] (${tool}) {xterm -bg black -fg red -e" \
        "'${tool} ${flags} ; bash'}" >> fluxbox-menu
    echo "      [end]" >> fluxbox-menu
    cat fluxbox-footer.tmpl >> fluxbox-menu

    return 0
}

make_openbox()
{
    cat openbox-header.tmpl > openbox-menu
    cat openbox-footer.tmpl >> openbox-menu

    return 0
}

make_awesome()
{
    cat awesome-header.tmpl > awesome-menu
    cat awesome-footer.tmpl >> awesome-menu

    return 0
}

make_fluxbox
#make_openbox
#make_awesome
