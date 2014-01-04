#!/bin/sh
#
# This script is an example hotplug script for use with the various
# input devices plugins.
#
# The script is called with the arguments:
# -t [added|present|removed] <device name>
#       added ... device was just plugged in
#       present.. device was present at gnome-settings-daemon startup
#       removed.. device was just removed
# -i <device ID>
#       device ID being the XInput device ID
# <device name> The name of the device
#
# The script should return 0 if the device is to be
# ignored from future configuration.
#
# Set the script to be used with:
# gsettings set org.gnome.settings-daemon.peripherals.input-devices hotplug-command /path/to/script/input-devices.sh
#

args=`getopt "t:i:" $*`

set -- $args

while [ $# -gt 0 ]
do
    case $1 in
    -t)
        shift;
        type="$1"
        ;;
     -i)
        shift;
        id="$1"
        ;;
     --)
        shift;
        device="$@"
        break;
        ;;
    *)
        echo "Unknown option $1";
        exit 1
        ;;
    esac
    shift
done

retval=0

case $type in
        added)
                echo "Device '$device' (ID=$id) was added"
                ;;
        present)
                echo "Device '$device' (ID=$id) was already present at startup"
                ;;
        removed)
                echo "Device '$device' (ID=$id) was removed"
                ;;
        *)
                echo "Unknown operation"
                retval=1
                ;;
esac

# All further processing will be disabled if $retval == 1
exit $retval
