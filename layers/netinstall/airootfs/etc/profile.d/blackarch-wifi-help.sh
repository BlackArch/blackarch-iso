# SPDX-License-Identifier: GPL-3.0-or-later
#
# Show Wi-Fi setup help at login on the NetInstall ISO.
#
# Sourced by /etc/profile for every login shell, so:
#   - never 'exit' here (it would end the login session); use 'return';
#   - keep it POSIX sh;
#   - only act for interactive shells on a terminal, so scp, rsync and
#     'ssh host command' are unaffected.
#
# wifi-help --login prints a single line when the machine is already
# online and the full guide only when it is not.

case $- in
  *i*) ;;
  *) return 0 ;;
esac
[ -t 1 ] || return 0

[ -x /usr/local/bin/wifi-help ] && /usr/local/bin/wifi-help --login
