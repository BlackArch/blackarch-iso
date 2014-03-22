#!/bin/sh
#
# generates list of packages for packages.x86_64 and packages.i686
#

WORKDIR="`pwd`/`dirname ${0}`"
ARCHS="x86_64 i686"
_GROUPS="`pacman -Sg | grep blackarch- | sort -u | tr -s '\n' ' '`"

if [ ${#} -ne 1 ]
then
  echo "${0} <packages_path>"
  exit 1337
else
  pkgpath="${1}"
fi

cd "`dirname ${pkgpath}`/`basename ${pkgpath}`"

for arch in ${ARCHS}
do
  cat "${WORKDIR}/packages.${arch}.tmpl" > "packages.${arch}"

  for group in ${_GROUPS}
  do
    tools=`grep -r "${group}" | cut -d '/' -f 1 | sort -u |
    grep -v "packages.${arch}"`
    echo "# ${group}" >> "packages.${arch}"
    for tool in ${tools}
    do
      grep -rE "'${arch}'|'any'" ${tool} | cut -d '/' -f 1 |
      sort -u >> "packages.${arch}"
    done
    echo "" >> "packages.${arch}"
  done
  mv "packages.${arch}" ${WORKDIR}
done
