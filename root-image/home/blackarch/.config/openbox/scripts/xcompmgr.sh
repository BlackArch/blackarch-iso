#!/bin/sh

case "$1" in
	set)
	killall xcompmgr
	sed -i 's/^[# ]*xcompmgr.*$/xcompmgr \&/g;s/^xcompmgr.*$/xcompmgr \&/g' ~/.config/openbox/autostart
	xcompmgr &
	;;
	unset)
	sed -i 's/^xcompmgr.*$/#xcompmgr \&/g' ~/.config/openbox/autostart
	killall xcompmgr
	;;
	setshaded)
	killall xcompmgr
	sed -i 's/^[# ]*xcompmgr.*$/xcompmgr -CfF \&/g;s/^xcompmgr.*$/xcompmgr -CfF \&/g' ~/.config/openbox/autostart
	xcompmgr -CfF &
	;;
	setshadowshade)
	killall xcompmgr
	sed -i 's/^[# ]*xcompmgr.*$/xcompmgr -CcfF \&/g;s/^xcompmgr.*$/xcompmgr -CcFf \&/g' ~/.config/openbox/autostart
	xcompmgr -CcfF &
	;;
	*)
		echo 'This script accepts the following arguments: set, setshaded, setshadowshade, unset'
	;;
esac
