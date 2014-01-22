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

make_fluxbox_header()
{
    cat fluxbox-header.tmpl > fluxbox-menu

    return 0;
}

make_fluxbox_footer()
{
    cat fluxbox-footer.tmpl >> fluxbox-menu

    return 0;
}

make_openbox_header()
{
    cat openbox-header.tmpl > openbox-menu

    return 0;
}

make_openbox_footer()
{
    cat openbox-footer.tmpl >> openbox-menu

    return 0;
}

make_awesome_header()
{
    cat awesome-header.tmpl > awesome-menu

    return 0;
}

make_awesome_footer()
{
    cat awesome-footer.tmpl >> awesome-menu

    return 0;
}

make_fluxbox_menu()
{
    echo "      [submenu] (${group})" >> fluxbox-menu
    echo "          [exec] (${tool}) {xterm -bg black -fg red -e" \
        "'${tool} ${flags} ; bash'}" >> fluxbox-menu
    echo "      [end]" >> fluxbox-menu

    return 0
}

make_openbox_menu()
{
    return 0
}

make_awesome_menu()
{
    return 0
}

make_menus()
{
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
                make_fluxbox_menu
                make_openbox
                make_awesome
            done
        done
    done

    return 0;
}

make_headers()
{
    make_fluxbox_header
    make_openbox_header
    make_awesome_header

    return 0;
}

make_footers()
{
    make_fluxbox_footer
    make_openbox_footer
    make_awesome_footer

    return 0;
}

make_headers
make_menus
make_footers
