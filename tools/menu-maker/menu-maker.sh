#!/bin/sh
#
# generates menus for fluxbox, openbox and awesome.


WORKDIR="`pwd`"
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

make_fluxbox_header()
{
    cat "${WORKDIR}/fluxbox-header.tmpl" > fluxbox-menu

    return 0
}

make_fluxbox_footer()
{
    cat "${WORKDIR}/fluxbox-footer.tmpl" >> fluxbox-menu

    return 0
}

make_openbox_header()
{
    cat "${WORKDIR}/openbox-header.tmpl" > openbox-menu

    return 0
}

make_openbox_footer()
{
    cat "${WORKDIR}/openbox-footer.tmpl" >> openbox-menu

    return 0
}

make_awesome_header()
{
    cat "${WORKDIR}/awesome-header.tmpl" > awesome-menu

    return 0
}

make_awesome_footer()
{
    cat "${WORKDIR}/awesome-footer.tmpl" >> awesome-menu

    return 0
}

fluxbox_start()
{
    echo "      [submenu] (${group})" >> fluxbox-menu

    return 0
}

fluxbox_entry()
{
    echo "          [exec] (${tool}) {xterm -bg black -fg red -e" \
        "'${tool} ${opts} bash'}" >> fluxbox-menu

    return 0
}

fluxbox_end()
{
    echo "      [end]" >> fluxbox-menu
    echo "" >> fluxbox-menu

    return 0;
}

openbox_start()
{
    echo "<menu id=\"${group}-menu\" label=\"`echo ${group} |
    cut -d '-' -f 2-`\">" >> openbox-menu

    return 0
}

openbox_entry()
{
    echo "  <item label=\"${tool}\">" >> openbox-menu
    echo "      <action name=\"Execute\">" >> openbox-menu
    echo "          <command>xterm -bg black -fg red -e '${tool}" \
        "${opts} bash'</command>" >> openbox-menu
    echo "      </action>" >> openbox-menu
    echo "  </item>" >> openbox-menu

    return 0
}

openbox_end()
{
    echo "</menu>" >> openbox-menu
    echo "" >> openbox-menu

    return 0
}

awesome_start()
{
    echo "`echo "${group}" | cut -d '-' -f 2- | tr -d '-'`menu = {" \
        >> awesome-menu

    return 0
}

awesome_entry()
{
    echo "  { \"${tool}\", \"xterm -bg black -fg red -e '${tool} ${opts}" \
        "bash'\" }," >> awesome-menu

    return 0
}

awesome_end()
{
    echo "}" >> awesome-menu
    echo "" >> awesome-menu

    return 0
}

make_menus()
{
    for group in ${_GROUPS}
    do
        fluxbox_start
        openbox_start
        awesome_start
        pkgs="`grep -r ${group} | cut -d '/' -f 1 | sort -u `"
        for p in ${pkgs}
        do
            tools="`pkgfile -lbq ${p} |
            awk -F'/' '/\/usr\/bin|\/usr\/sbin|\/usr\/share/ {print $(NF)}'`"
            for tool in ${tools}
            do
                opts="`grep "^${tool} " "${WORKDIR}/help-flags.txt" |
                cut -d ' ' -f 2-`"
                if [ -z "${opts}" ]
                then
                    echo "[WARNING]: ${tool} (${p}) not added to help-flags.txt"
                    opts=";"
                fi
                fluxbox_entry
                openbox_entry
                awesome_entry
            done
        done
        fluxbox_end
        openbox_end
        awesome_end
    done

    return 0
}

make_openbox_extras()
{
    echo "<menu id=\"root-menu\" label=\"Openbox 3\">" >> openbox-menu
    echo "  <separator label=\"applications\" />" >> openbox-menu
    echo "  <menu id=\"terminals-menu\"/>" >> openbox-menu
    echo "  <menu id=\"browsers-menu\"/>" >> openbox-menu
    echo "  <separator label=\"blackarch\" />" >> openbox-menu

    for group in ${_GROUPS}
    do
        echo "  <menu id=\"${group}-menu\"/>" >> openbox-menu
    done

    echo "  <separator label=\"system\" />" >> openbox-menu
    echo "  <menu id=\"system-menu\" />" >> openbox-menu
    echo "  <separator />" >> openbox-menu
    echo "  <item label=\"log out\">" >> openbox-menu
    echo "  <action name=\"exit\">" >> openbox-menu
    echo "      <prompt>yes</prompt>" >> openbox-menu
    echo "  </action>" >> openbox-menu
    echo "  </item>" >> openbox-menu
    echo "</menu>" >> openbox-menu

    return 0
}

make_awesome_extras()
{
    echo "blackarchmenu = {" >> awesome-menu

    for group in ${_GROUPS}
    do
        echo "  { \"`echo "${group}" | cut -d '-' -f 2-`\", `echo "${group}" |
        cut -d '-' -f 2- | tr -d '-'`menu }," >> awesome-menu
    done

    echo "}" >> awesome-menu

    return 0
}


make_extras()
{
    make_openbox_extras
    make_awesome_extras

    return 0
}

make_headers()
{
    make_fluxbox_header
    make_openbox_header
    make_awesome_header

    return 0
}

make_footers()
{
    make_fluxbox_footer
    make_openbox_footer
    make_awesome_footer

    return 0
}

move_menus()
{
    mv fluxbox-menu openbox-menu awesome-menu ${WORKDIR}

    return 0
}

cd "`dirname ${pkgpath}`/`basename ${pkgpath}`"

make_headers
make_menus
make_extras
make_footers
move_menus
