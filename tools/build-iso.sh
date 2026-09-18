#!/bin/bash
#
# Build a BlackArch ISO with archiso.
#
# Usage: ./build-iso.sh [--class full|slim|netinstall] [options]
#

set -eo pipefail

# ---------------------------------------------------------------------------
# Defaults (environment variables still work as before)
# ---------------------------------------------------------------------------
validClasses=("full" "slim" "netinstall")

name="${ID:-blackarch-linux}"
version="${ISO_VERSION:-$(date +%Y.%m.%d)}"
class=$(printf '%s' "${VARIANT:-slim}" | tr '[:upper:]' '[:lower:]')
arch="${ISO_ARCHITECTURE:-x86_64}"
cleanCache="yes"
keepBuild="no"

archisoRequiredVersion="archiso 90-1"

# Resolve paths relative to this script, so it works from any directory
scriptDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repoDir="$(cd "$scriptDir/.." && pwd)"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
usage() {
  cat << EOF
Usage: $(basename "$0") [options]

Options:
  -c, --class CLASS       ISO variant: $(IFS="|"; echo "${validClasses[*]}") (default: $class)
  -V, --version VERSION   ISO version string (default: $version)
  -a, --arch ARCH         Architecture (default: $arch)
  -n, --name NAME         ISO name prefix (default: $name)
      --no-clean-cache    Do not run 'pacman -Scc' before building
      --keep-build        Keep the build folder after building
  -h, --help              Show this help

Examples:
  $(basename "$0") --class full
  $(basename "$0") -c netinstall -V 2026.09.17
  $(basename "$0") --class=slim --keep-build
EOF
}

die() {
  tput setaf 1 2> /dev/null || true
  echo "ERROR: $*" >&2
  tput sgr0 2> /dev/null || true
  exit 1
}

phase() {
  echo
  echo "##################################################################"
  tput setaf 2 2> /dev/null || true
  echo "$1"
  shift
  for line in "$@"; do echo "- $line"; done
  tput sgr0 2> /dev/null || true
  echo "##################################################################"
  echo
}

# Accepts both "--opt value" and "--opt=value"
need_value() {
  [ -n "$2" ] && [ "${2:0:1}" != "-" ] || die "Option '$1' requires a value"
}

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------
while [ $# -gt 0 ]; do
  case "$1" in
    -c|--class)    need_value "$1" "${2:-}"; class="$2"; shift 2 ;;
    --class=*)     class="${1#*=}"; shift ;;
    -V|--version)  need_value "$1" "${2:-}"; version="$2"; shift 2 ;;
    --version=*)   version="${1#*=}"; shift ;;
    -a|--arch)     need_value "$1" "${2:-}"; arch="$2"; shift 2 ;;
    --arch=*)      arch="${1#*=}"; shift ;;
    -n|--name)     need_value "$1" "${2:-}"; name="$2"; shift 2 ;;
    --name=*)      name="${1#*=}"; shift ;;
    --no-clean-cache) cleanCache="no"; shift ;;
    --keep-build)  keepBuild="yes"; shift ;;
    -h|--help)     usage; exit 0 ;;
    *)             usage; echo; die "Unknown option: $1" ;;
  esac
done

# Validate class
valid="no"
for c in "${validClasses[@]}"; do
  [ "$class" == "$c" ] && valid="yes"
done
[ "$valid" == "yes" ] || die "Invalid class '$class'. Valid: ${validClasses[*]}"

layersDir="$repoDir/layers"
[ -d "$layersDir/$class" ] || die "Variant layer not found: $layersDir/$class"

isoLabel="$name-$class-$version-$arch.iso"
buildFolder="$HOME/$name-$class-build"
workFolder="$buildFolder/work"
profileCopy="$buildFolder/profile"
outFolder="$HOME/$name-out"

# ---------------------------------------------------------------------------
phase "Phase 1 :" "Checking archiso" "Setting general parameters"
# ---------------------------------------------------------------------------
if ! pacman -Qi archiso &> /dev/null; then
  echo "Installing archiso"
  sudo pacman -S --noconfirm archiso
  pacman -Qi archiso &> /dev/null || die "archiso has NOT been installed"
fi

archisoVersion="$(pacman -Q archiso)"

echo "Class                                  : $class"
echo "Building version                       : $version"
echo "Iso label                              : $isoLabel"
echo "Installed archiso version              : $archisoVersion"
echo "Required archiso version               : $archisoRequiredVersion"
echo "Profile layers                         : $("$scriptDir/merge-profile.sh" --list | grep "^$class:" | cut -d: -f2)"
echo "Build folder                           : $buildFolder"
echo "Out folder                             : $outFolder"

if [ "$archisoVersion" == "$archisoRequiredVersion" ]; then
  tput setaf 2 2> /dev/null || true
  echo "Archiso has the correct version. Continuing ..."
  tput sgr0 2> /dev/null || true
else
  tput setaf 3 2> /dev/null || true
  echo "WARNING: archiso version differs from the required one."
  echo "Use 'sudo downgrade archiso' or update your system if the build fails."
  tput sgr0 2> /dev/null || true
fi

if [ -f "$repoDir/archiso.readme" ]; then
  echo "Saving current archiso version to readme"
  sed -i "s/\(^archiso-version=\).*/\1$archisoVersion/" "$repoDir/archiso.readme"
fi

# ---------------------------------------------------------------------------
phase "Phase 2 :" "Deleting the build folder if one exists" "Assembling the $class profile from layers"
# ---------------------------------------------------------------------------
[ -d "$buildFolder" ] && sudo rm -rf "$buildFolder"
mkdir -p "$workFolder"
"$scriptDir/merge-profile.sh" "$class" "$profileCopy"

# ---------------------------------------------------------------------------
phase "Phase 3 :" "Using /etc/skel/.bashrc from layers/base (no download needed)"
# ---------------------------------------------------------------------------
[ -f "$profileCopy/airootfs/etc/skel/.bashrc" ] || die "No .bashrc in merged profile"

# ---------------------------------------------------------------------------
phase "Phase 4 :" "Adding build time and release to /etc/dev-rel"
# ---------------------------------------------------------------------------
devRel="$profileCopy/airootfs/etc/dev-rel"
if [ -f "$devRel" ]; then
  date_build="$(date -d now)"
  echo "Iso built on : $date_build"
  sed -i "s|\(^ISO_BUILD=\).*|\1$date_build|" "$devRel"
  sed -i "s|\(^ISO_RELEASE=\).*|\1$version|" "$devRel"
else
  echo "No /etc/dev-rel in profile, skipping"
fi

# ---------------------------------------------------------------------------
if [ "$cleanCache" == "yes" ]; then
  phase "Phase 5 :" "Cleaning the cache from /var/cache/pacman/pkg/"
  yes | sudo pacman -Scc || true
else
  phase "Phase 5 :" "Skipping pacman cache cleaning (--no-clean-cache)"
fi

# ---------------------------------------------------------------------------
phase "Phase 6 :" "Building the $class iso - this can take a while - be patient"
# ---------------------------------------------------------------------------
mkdir -p "$outFolder"

# Remember existing ISOs so we can find the new one afterwards
startMarker="$(mktemp)"
trap 'rm -f "$startMarker"' EXIT

sudo mkarchiso -v -w "$workFolder" -o "$outFolder" "$profileCopy"

# mkarchiso names the ISO from profiledef.sh (iso_name/iso_version/arch),
# so find the file it just created and rename it to our label.
builtIso="$(find "$outFolder" -maxdepth 1 -name '*.iso' -newer "$startMarker" -printf '%T@ %p\n' \
  | sort -nr | head -n1 | cut -d' ' -f2-)"
[ -n "$builtIso" ] || die "mkarchiso finished but no new ISO was found in $outFolder"

if [ "$(basename "$builtIso")" != "$isoLabel" ]; then
  sudo mv -f "$builtIso" "$outFolder/$isoLabel"
fi
sudo chown "$(id -u):$(id -g)" "$outFolder/$isoLabel"

# ---------------------------------------------------------------------------
phase "Phase 7 :" "Creating checksums for $isoLabel"
# ---------------------------------------------------------------------------
cd "$outFolder"   # keeps absolute paths out of the checksum files
for algo in md5 sha1 sha256 sha512; do
  echo "Building ${algo}sum"
  "${algo}sum" "$isoLabel" | tee "$isoLabel.$algo"
done

# ---------------------------------------------------------------------------
if [ "$keepBuild" == "yes" ]; then
  phase "Phase 8 :" "Keeping build folder: $buildFolder"
else
  phase "Phase 8 :" "Deleting the build folder"
  sudo rm -rf "$buildFolder"
fi

tput setaf 2 2> /dev/null || true
echo "DONE"
echo "ISO: $outFolder/$isoLabel"
tput sgr0 2> /dev/null || true
