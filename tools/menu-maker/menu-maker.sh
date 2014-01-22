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
else
    pkgpath="${1}"
fi

cd "`dirname ${pkgpath}`/`basename ${pkgpath}`"

make_fluxbox()
{
    cat fluxbox-header.tmpl > fluxbox-menu
    echo "      [submenu] (${group})" >> fluxbox-menu
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

for group in ${_GROUPS}
do
    pkgs="`grep -r ${group} | cut -d '/' -f 1 | sort -u `"
    for p in ${pkgs}
    do
        tools="`pkgfile -lbq ${p} |
        awk '/\/usr\/bin|\/usr\/sbin|\/usr\/share/ {print $2}'`"
        for tool in ${tools}
        do
            flags=""
            #make_fluxbox
            #make_openbox
            #make_awesome
        done
    done
done
