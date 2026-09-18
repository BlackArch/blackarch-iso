#!/bin/bash
#
# Assemble a complete archiso profile for one BlackArch variant by stacking
# the layers in ../layers/ on top of each other.
#
# Usage: ./merge-profile.sh <variant> <output-dir>
#        ./merge-profile.sh --list
#
# How layering works:
#   * Layers are copied in order; a file in a later layer replaces the file
#     with the same path from an earlier layer (the variant layer always wins).
#   * packages.x86_64 is NOT replaced: the lists from every layer are
#     concatenated, so each layer only lists the packages it adds.
#
#   * Files ending in ".in" are templates: @PLACEHOLDERS@ are filled from the
#     variant layer's variant.conf (e.g. the ISO name in the boot menus).
#
# To add a variant: create layers/<name>/ with a variant.conf (copy one from
# another variant) and add a line to the VARIANT_LAYERS table below.
#

set -eo pipefail

# variant -> ordered list of layers (last one wins)
declare -A VARIANT_LAYERS=(
  [full]="base graphical full"
  [slim]="base graphical slim"
  [netinstall]="base netinstall"
)

scriptDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
layersDir="$(cd "$scriptDir/../layers" && pwd)"

die() { echo "ERROR: $*" >&2; exit 1; }

if [ "${1:-}" == "--list" ]; then
  for v in "${!VARIANT_LAYERS[@]}"; do echo "$v: ${VARIANT_LAYERS[$v]}"; done | sort
  exit 0
fi

[ $# -eq 2 ] || die "usage: $(basename "$0") <variant> <output-dir> | --list"
variant="$1"
out="$2"

[ -n "${VARIANT_LAYERS[$variant]+x}" ] \
  || die "unknown variant '$variant' (known: ${!VARIANT_LAYERS[*]})"
[ ! -e "$out" ] || [ -z "$(ls -A "$out")" ] \
  || die "output directory '$out' is not empty"

mkdir -p "$out"
pkgList="$out/packages.x86_64"
tmpPkgs="$(mktemp)"
trap 'rm -f "$tmpPkgs"' EXIT

for layer in ${VARIANT_LAYERS[$variant]}; do
  src="$layersDir/$layer"
  [ -d "$src" ] || die "layer not found: $src"
  echo "  + layer: $layer"
  # -a keeps symlinks, modes and timestamps; trailing /. copies dotfiles too.
  # --remove-destination lets a regular file replace a symlink (and vice
  # versa) coming from an earlier layer instead of writing through it.
  cp -a --remove-destination "$src"/. "$out"/
  if [ -f "$src/packages.x86_64" ]; then
    { echo "# ---- from layer: $layer ----"; cat "$src/packages.x86_64"; echo; } >> "$tmpPkgs"
  fi
done

mv "$tmpPkgs" "$pkgList"
chmod 644 "$pkgList"
trap - EXIT

# ---------------------------------------------------------------------------
# Templates: every "<file>.in" becomes "<file>" with @VAR@ placeholders filled
# from the variant's variant.conf. A plain "<file>" provided by any layer takes
# precedence over the template (so a variant can still fully override one).
# ---------------------------------------------------------------------------
TEMPLATE_VARS=(VARIANT_ID VARIANT_NAME ISO_NAME VARIANT_PURPOSE FILE_PERMISSIONS)
conf="$out/variant.conf"
[ -f "$conf" ] || die "no variant.conf found in layers/$variant"
# shellcheck disable=SC1090
( set -u; source "$conf"; for v in "${TEMPLATE_VARS[@]}"; do : "${!v}"; done ) \
  || die "variant.conf of '$variant' must define: ${TEMPLATE_VARS[*]}"
source "$conf"
rm -f "$conf"

# bash >= 5.2 treats '&' in ${x//pat/rep} specially; we want it literal
shopt -u patsub_replacement 2> /dev/null || true

while IFS= read -r -d '' tpl; do
  target="${tpl%.in}"
  if [ -e "$target" ] || [ -L "$target" ]; then
    rm -f "$tpl"                       # a layer supplied the real file
    continue
  fi
  content="$(cat "$tpl"; echo x)"      # the 'x' preserves trailing newlines
  content="${content%x}"
  for v in "${TEMPLATE_VARS[@]}"; do
    val="${!v}"
    val="${val#"${val%%[!$'\n']*}"}"  # drop leading newlines (multi-line values)
    content="${content//@$v@/$val}"
  done
  if leftover="$(grep -o '@[A-Z_]\+@' <<< "$content" | sort -u | tr '\n' ' ')" \
     && [ -n "$leftover" ]; then
    die "unknown placeholder(s) in ${tpl#"$out"/}: $leftover"
  fi
  printf '%s' "$content" > "$target"
  chmod --reference="$tpl" "$target"
  rm -f "$tpl"
done < <(find "$out" -name '*.in' -type f -print0)

# Safety net: a package listed by two layers is almost always a mistake
dups="$(sed 's/#.*//; s/[[:space:]]//g; /^$/d' "$pkgList" | sort | uniq -d)"
if [ -n "$dups" ]; then
  echo "WARNING: packages listed in more than one layer:" >&2
  echo "$dups" | sed 's/^/    /' >&2
fi

[ -f "$out/profiledef.sh" ] || die "merged profile has no profiledef.sh"
echo "  = $variant profile assembled in $out"
