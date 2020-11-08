# Translations for the Welcome app.
#
# Note: variables (like $PRETTY_PROGNAME below) may be used if they are already defined either
# - in the Welcome app
# - globally
#
#
# Any string should be defined like:
#
#    _tr_add <language> <placeholder> "string"
#          or
#    _tr_add2 <placeholder> "string"
#
# where
#
#    _tr_add         A bash function that adds a "string" to the strings database.
#    _tr_add2        Same as _tr_add but knows the language from the _tr_lang variable (below).
#    <language>      An acronym for the language, e.g. "en" for English (check the LANG variable!).
#    <placeholder>   A pre-defined name that identifies the place in the Welcome app where this string is used.
#    "string"        The translated string for the Welcome app.

# English:

### First some useful definitions:

_tr_lang=en            # required helper variable for _tr_add2

# Help with some special characters (HTML). Yad has problems without them:
_exclamation='&#33;'   # '!'
_and='&#38;'           # '&'
_question='&#63;'      # '?'


###################### Now the actual strings to be translated: ######################
# func   <placeholder>         "string"

_tr_add2 welcome_disabled      "<eos1($PRETTY_PROGNAME)> app is disabled. To start it, use switch <eos2(--enable)>."

_tr_add2 butt_later            "See you later"
_tr_add2 butt_latertip         "Keep <eos1($PRETTY_PROGNAME)> enabled"

_tr_add2 butt_noshow           "Don't show me anymore"
_tr_add2 butt_noshowtip        "Disable <eos1($PRETTY_PROGNAME)>"

_tr_add2 butt_help             "Help"


_tr_add2 nb_tab_INSTALL        "INSTALL"
_tr_add2 nb_tab_GeneralInfo    "General Info"
_tr_add2 nb_tab_AfterInstall   "After Install"
_tr_add2 nb_tab_AddMoreApps    "Add More Apps"


_tr_add2 after_install_text    "After install tasks"

_tr_add2 after_install_um      "Update Mirrors"
_tr_add2 after_install_umtip   "Update list of mirrors before system update"

_tr_add2 after_install_us      "Update System"
_tr_add2 after_install_ustip   "Update System Software"

_tr_add2 after_install_dsi     "Detect system issues"
_tr_add2 after_install_dsitip  "Detect any potential issues on system packages or elsewhere"

_tr_add2 after_install_etl     "blackarch to latest$_question"
_tr_add2 after_install_etltip  "Show what to do to get your system to the latest blackarch level"

_tr_add2 after_install_cdm     "Change Display Manager"
_tr_add2 after_install_cdmtip  "Use a different display manager"

_tr_add2 after_install_ew      "blackarch wallpaper"
_tr_add2 after_install_ewtip   "Change desktop wallpaper to blackarch default"


_tr_add2 after_install_pm      "Package management"
_tr_add2 after_install_pmtip   "How to manage packages with pacman"

_tr_add2 after_install_ay      "AUR $_and yay$_exclamation"
_tr_add2 after_install_aytip   "<eos1(Arch User Repository)> and <eos2(yay)> info"

_tr_add2 after_install_hn      "Hardware and Network"
_tr_add2 after_install_hntip   "Tips for your hardware"

_tr_add2 after_install_bt      "Bluetooth"
_tr_add2 after_install_bttip   "Bluetooth advice"

_tr_add2 after_install_nv      "NVIDIA users$_exclamation"
_tr_add2 after_install_nvtip   "Use NVIDIA installer"

_tr_add2 after_install_ft      "Forum tips"
_tr_add2 after_install_fttip   "Help us help you!"


_tr_add2 general_info_text     "Find your way at the blackarch website$_exclamation"

_tr_add2 general_info_ws       "Web site"

_tr_add2 general_info_wi       "Wiki"
_tr_add2 general_info_witip    "Featured articles"

_tr_add2 general_info_ne       "News"
_tr_add2 general_info_netip    "News and articles"

_tr_add2 general_info_fo       "Forum"
_tr_add2 general_info_fotip    "Ask, comment, and chat in our friendly forum!"

_tr_add2 general_info_do       "Donate"
_tr_add2 general_info_dotip    "Help us keep blackarch running"

_tr_add2 general_info_ab       "About <eos1($PRETTY_PROGNAME)>"
_tr_add2 general_info_abtip    "More info about this app"


_tr_add2 add_more_apps_text    "Install popular apps"

_tr_add2 add_more_apps_lotip   "Office tools (<eos1(libreoffice-fresh)>)"

_tr_add2 add_more_apps_ch      "<eos1(Chromium)> Web Browser"
_tr_add2 add_more_apps_chtip   "Web Browser"

_tr_add2 add_more_apps_fw      "Firewall"
_tr_add2 add_more_apps_fwtip   "<eos1(Gufw)> firewall"

_tr_add2 add_more_apps_bt      "<eos1(Bluetooth)> [<eos2(blueberry)>] for <eos3(Xfce)>"
_tr_add2 add_more_apps_bt_bm   "<eos1(Bluetooth)> [<eos2(blueman)>] for <eos3(Xfce)>"


####################### NEW STUFF AFTER THIS LINE:

_tr_add2 settings_dis_contents   "To run <eos1($PRETTY_PROGNAME)> again, start a terminal and run: <eos2($PROGNAME --enable)>"
_tr_add2 settings_dis_text       "Enabling <eos1($PRETTY_PROGNAME:)>"
_tr_add2 settings_dis_title      "How to enable <eos1($PRETTY_PROGNAME)>"
_tr_add2 settings_dis_butt       "I remember"
_tr_add2 settings_dis_buttip     "I promise"

_tr_add2 help_butt_title         "<eos1($PRETTY_PROGNAME)> Help"
_tr_add2 help_butt_text          "More info about the <eos1($PRETTY_PROGNAME)> app"

_tr_add2 dm_title                "Select Display Manager"
_tr_add2 dm_col_name1            "Selected"
_tr_add2 dm_col_name2            "DM name"

_tr_add2 dm_reboot_required      "Reboot is required for the changes to take effect."
_tr_add2 dm_changed              "DM changed to: "
_tr_add2 dm_failed               "Changing DM failed."
_tr_add2 dm_warning_title        "Warning"

_tr_add2 install_installer       "Installer"
_tr_add2 install_already         "already installed"
_tr_add2 install_ing             "Installing"
_tr_add2 install_done            "Finished."

_tr_add2 sysup_no                "No updates."
_tr_add2 sysup_check             "Checking for software updates..."

_tr_add2 issues_title            "Package issue detection"
_tr_add2 issues_grub             "IMPORTANT: re-creating boot menu manually will be needed."
_tr_add2 issues_run              "Running commands:"
_tr_add2 issues_no               "No important system issues were detected."

_tr_add2 cal_noavail            "Not available: "        # installer program
_tr_add2 cal_warn               "Warning"
_tr_add2 cal_info1              "This is a community development release.<eos1(<br><br>)>"                                   # specials needed!
_tr_add2 cal_info2              "<eos1(<b>Offline</b>)> method gives you an Xfce desktop with blackarch theming.<eos2(\n)>Internet connection is not needed.<eos3(<br><br>)>"
_tr_add2 cal_info3              "<eos1(<b>Online</b>)> method lets you choose your desktop, with vanilla theming.<eos2(\n)>Internet connection is required.<eos3(<br><br>)>"
_tr_add2 cal_info4              "Please Note: This release is a work in progress, please help us making it stable by reporting bugs.<eos1(\n)>"
_tr_add2 cal_choose             "Choose installation method"
_tr_add2 cal_method             "Method"
_tr_add2 cal_nosupport          "<eos1($PROGNAME)>: unsupported mode: "
_tr_add2 cal_nofile             "<eos1($PROGNAME)>: required file does not exist: "
_tr_add2 cal_istarted           "Install started"
_tr_add2 cal_istopped           "Install finished"

_tr_add2 tail_butt              "Close this window"
_tr_add2 tail_buttip            "Close only this window"


_tr_add2 ins_text              "Installing blackarch to disk"
_tr_add2 ins_start             "Start the Installer"
_tr_add2 ins_starttip          "Start the blackarch installer along with a debug terminal"
_tr_add2 ins_up                "Update this app$_exclamation"
_tr_add2 ins_uptip             "Updates this app and restarts it"
_tr_add2 ins_keys              "Initialize <eos1(pacman)> keys"
_tr_add2 ins_keystip           "Initialize <eos1(pacman)> keys"
_tr_add2 ins_pm                "Partition manager"
_tr_add2 ins_pmtip             "<eos1(Gparted)> allows examining and managing disk partitions and structure"
_tr_add2 ins_rel               "Latest release info"
_tr_add2 ins_reltip            "More info about the latest release"
_tr_add2 ins_tips              "Installation tips"
_tr_add2 ins_tipstip           "Installation tips"
_tr_add2 ins_trouble           "Troubleshoot"
_tr_add2 ins_troubletip        "System Rescue"

_tr_add2 after_install_us_from    "Updates from"                            # AUR or upstream
_tr_add2 after_install_us_el      "Elevated privileges required."
_tr_add2 after_install_us_done    "update done."
_tr_add2 after_install_us_fail    "update failed!"
