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

# German:

### First some useful definitions:

_tr_lang=de            # required helper variable for _tr_add2

# Help with some special characters (HTML). Yad has problems without them:
_exclamation='&#33;'   # '!'
_and='&#38;'           # '&'
_question='&#63;'      # '?'


###################### Now the actual strings to be translated: ######################
# func   <placeholder>         "string"

_tr_add2 welcome_disabled      "$PRETTY_PROGNAME app ist deaktiviert. Um sie trotzdem zu starten, benutze --enable."

_tr_add2 butt_later            "Bis Später"
_tr_add2 butt_latertip         "Behalte $PRETTY_PROGNAME aktiviert"

_tr_add2 butt_noshow           "Nicht mehr automatisch starten"
_tr_add2 butt_noshowtip        "Deaktiviere $PRETTY_PROGNAME"

_tr_add2 butt_help             "Hilfe"


_tr_add2 nb_tab_INSTALL        "Installiere"
_tr_add2 nb_tab_GeneralInfo    "Allgemeine Informationen"
_tr_add2 nb_tab_AfterInstall   "Nach der Installation"
_tr_add2 nb_tab_AddMoreApps    "Füge mehr Programme hinzu"


_tr_add2 after_install_text    "Erledigungen nach der Installation"

_tr_add2 after_install_um      "Erneuere die Spiegelserver Liste"
_tr_add2 after_install_umtip   "Erneuere die Liste der Spiegelserver vor dem Systemupdate"

_tr_add2 after_install_us      "System Update"
_tr_add2 after_install_ustip   "System Software Update"

_tr_add2 after_install_dsi     "Suche nach System Problemen"
_tr_add2 after_install_dsitip  "Sucht nach Problemen mit Systemeinstellungen oder Paketen"

_tr_add2 after_install_etl     "blackarch auf dem letzten Stand$_question"
_tr_add2 after_install_etltip  "Zeigt an was zu tun ist um das System auf den neuesten blackarch Stand zu bringen"

_tr_add2 after_install_cdm     "Ändere den Login-Manager"
_tr_add2 after_install_cdmtip  "benutze einen anderen Login-Manager"

_tr_add2 after_install_ew      "blackarch Bildschirm-Hintergrund"
_tr_add2 after_install_ewtip   "Benutze den blackarch Bildschirm-Hintergrund"


_tr_add2 after_install_pm      "Paket Verwaltung"
_tr_add2 after_install_pmtip   "Wie verwalte ich meine Pakete mit pacman"

_tr_add2 after_install_ay      "AUR $_and yay$_exclamation"
_tr_add2 after_install_aytip   "Arch User Repository und yay info"

_tr_add2 after_install_hn      "Hardware und Netzwerk"
_tr_add2 after_install_hntip   "Bring deine Hardware zum Laufen"

_tr_add2 after_install_bt      "Bluetooth"
_tr_add2 after_install_bttip   "Bluetooth Informationen"

_tr_add2 after_install_nv      "NVIDIA Nutzer$_exclamation"
_tr_add2 after_install_nvtip   "Wie funktioniert der Nvidia-Installer"

_tr_add2 after_install_ft      "Forum Tipps"
_tr_add2 after_install_fttip   "Hilf uns dir zu helfen$_exclamation"


_tr_add2 general_info_text     "Finde dich auf der blackarch Webseite zurecht$_exclamation"

_tr_add2 general_info_ws       "Webseite"

_tr_add2 general_info_wi       "Wiki"
_tr_add2 general_info_witip    "Interessante Einträge"

_tr_add2 general_info_ne       "Neuigkeiten"
_tr_add2 general_info_netip    "Neuigkeiten und Berichte"

_tr_add2 general_info_fo       "Forum"
_tr_add2 general_info_fotip    "Erhalte Hilfe in unserem freundlichen und offenem Forum"

_tr_add2 general_info_do       "Spenden"
_tr_add2 general_info_dotip    "Unterstütze unsere Arbeit mit einer Spende"

_tr_add2 general_info_ab       "Über $PRETTY_PROGNAME"
_tr_add2 general_info_abtip    "Wichtige Informationen über diese App"


_tr_add2 add_more_apps_text    "Installiere zusätzliche Programme"

_tr_add2 add_more_apps_lotip   "Office Anwendung (libreoffice-fresh)"

_tr_add2 add_more_apps_ch      "Chromium Web Browser"
_tr_add2 add_more_apps_chtip   "Web Browser"

_tr_add2 add_more_apps_fw      "Firewall"
_tr_add2 add_more_apps_fwtip   "Gufw Firewall"

_tr_add2 add_more_apps_bt      "Bluetooth (blueberry) für Xfce4"
_tr_add2 add_more_apps_bt_bm   "Bluetooth (blueman) für Xfce4"


####################### NEW STUFF AFTER THIS LINE:

_tr_add2 settings_dis_contents   "Um $PRETTY_PROGNAME wieder verfügbar zu machen führe diesen Befehl in einem Terminal aus: $PROGNAME --enable"
_tr_add2 settings_dis_text       "Wiederaktivierung $PRETTY_PROGNAME:"
_tr_add2 settings_dis_title      "Wie kann ich $PRETTY_PROGNAME wieder Aktivieren?"
_tr_add2 settings_dis_butt       "Ich werde mir das merken$_exclamation"
_tr_add2 settings_dis_buttip     "versprochen"

_tr_add2 help_butt_title         "$PRETTY_PROGNAME Hilfe"
_tr_add2 help_butt_text          "Mehr Informationen über das $PRETTY_PROGNAME Programm"

_tr_add2 dm_title                "Wähle einen anderen Anmelde Manager"
_tr_add2 dm_col_name1            "Ausgewählt"
_tr_add2 dm_col_name2            "DM Name"

_tr_add2 dm_reboot_required      "Neustart ist erforderlich um die Änderungen anzuwenden."
_tr_add2 dm_changed              "Neuer DM: "
_tr_add2 dm_failed               "Änderung des DM fehlgeschlagen."
_tr_add2 dm_warning_title        "Warnung"

_tr_add2 install_installer       "Installateur"
_tr_add2 install_already         "bereits installiert"
_tr_add2 install_ing             "installiere"
_tr_add2 install_done            "Abgeschlossen."

_tr_add2 sysup_no                "Keine Updates verfügbar."
_tr_add2 sysup_check             "Überprüfe auf neue Updates..."

_tr_add2 issues_title            "Überprüfe auf Paketprobleme"
_tr_add2 issues_grub             "WICHTIG: Eine manuelle Neuerstellung des Bootmenüs ist erforderlich."
_tr_add2 issues_run              "Führe Befehle aus:"
_tr_add2 issues_no               "Es wurden keine wichtigen Systemprobleme festgestellt."

_tr_add2 cal_noavail            "Nicht verfügbar: "        # installer program
_tr_add2 cal_warn               "Warnung"
_tr_add2 cal_info1              "Dies ist eine Community-Entwicklungsversion.\n\n"                                   # specials needed!
_tr_add2 cal_info2              "<b>Offline</b>Mit dieser Methode erhältst du einen Xfce4-Desktop mit blackarch-Theme.\nKeine Internetverbindung erforderlich.\n\n"
_tr_add2 cal_info3              "<b>Online</b> Mit dieser Methode kannst du eine der Desktop-Umgebungen ohne verändertes Thema auswählen.\nEs wird eine Internetverbindung benötigt.\n\n"
_tr_add2 cal_info4              "Bitte beachten Sie: Diese Version ist in Entwicklung. Bitte hilf uns, sie besser zu machen, indem du Fehler meldest.\n"
_tr_add2 cal_choose             "Wähle die Installationsmethode"
_tr_add2 cal_method             "Methode"
_tr_add2 cal_nosupport          "$PROGNAME: Methode nicht unterstützt: "
_tr_add2 cal_nofile             "$PROGNAME: benötigte Datei nicht verfügbar: "
_tr_add2 cal_istarted           "Beginne mit der Installation"
_tr_add2 cal_istopped           "Installation Beendet"

_tr_add2 tail_butt              "Schließe diese Fenster"
_tr_add2 tail_buttip            "Schließe nur dieses Fenster"


_tr_add2 ins_text              "blackarch auf deine Festplatte installieren$_exclamation"
_tr_add2 ins_start             "Starte den Installer"
_tr_add2 ins_starttip          "Starte den blackarch Installer zusammen mit der Terminalausgabe"
_tr_add2 ins_up                "Update dieses Programm$_exclamation"
_tr_add2 ins_uptip             "Update dieses Programm und starte es neu"
_tr_add2 ins_keys              "Initialisiere Pacman-Schlüssel"
_tr_add2 ins_keystip           "Initialisiere die von Pacman benötigten Schlüsseldateien"
_tr_add2 ins_pm                "Partition manager"
_tr_add2 ins_pmtip             "Gparted: ermöglicht das Untersuchen und Verwalten von Festplattenpartitionen und -Strukturen"
_tr_add2 ins_rel               "Informationen zur neusten Veröffentlichung"
_tr_add2 ins_reltip            "Mehr Informationen zur neusten Veröffentlichung"
_tr_add2 ins_tips              "Installationstipps"
_tr_add2 ins_tipstip           "Installationstipps"
_tr_add2 ins_trouble           "Fehlerbehebung"
_tr_add2 ins_troubletip        "Systemrettung"

_tr_add2 after_install_us_from    "Updates von"                            # AUR or upstream
_tr_add2 after_install_us_el      "Erweiterte Rechte werden benötigt."
_tr_add2 after_install_us_done    "Update erledigt."
_tr_add2 after_install_us_fail    "Update fehlgeschlagen$_exclamation"

# 2020-May-14:

_tr_add2 nb_tab_UsefulTips     "Tipps"
_tr_add2 useful_tips_text      "Hilfreiche Tipps"

# 2020-May-16:

_tr_add2 butt_changelog        "Änderungsprotokoll"
_tr_add2 butt_changelogtip     "Zeige Änderungsprotokoll von Welcome"

_tr_add2 after_install_themevan      "Xfce vanilla Thema"
_tr_add2 after_install_themevantip   "Benutze das unveränderte eingebaute Thema von Xfce"

_tr_add2 after_install_themedef     "Xfce blackarch Thema"
_tr_add2 after_install_themedeftip  "Benutze das blackarch Xfce Thema"

# 2020-Jun-28:
_tr_add2 after_install_pclean       "Paket Cache Bereinigung"
_tr_add2 after_install_pcleantip    "Konfiguriere den Paket Cache Bereinigungsservice"

# 2020-Jul-04:
_tr_add2 nb_tab_OwnCommands         "Persönliche Befehle"                   # modified 2020-Jul-08
_tr_add2 nb_tab_owncmds_text        "Personalisierte Befehle"               # modified 2020-Jul-08

# 2020-Jul-08:
_tr_add2 nb_tab_owncmdstip          "Hilfestellung für persönliche Befehle"

_tr_add2 add_more_apps_akm          "Ein Kernel Manager"
_tr_add2 add_more_apps_akmtip       "Ein kleines Kernel Paket Manager und Info Tool"

# 2020-Jul-15:
_tr_add2 butt_owncmds_help        "Anleitung: Persönliche Befehle"

# 2020-Aug-05:
_tr_add2 butt_owncmds_dnd         "Persönliche Befehle drag${_and}drop"
_tr_add2 butt_owncmds_dnd_help    "Zeige das Eingabe Fenster zum Einfügen der Befehle"

# 2020-Sep-03:
_tr_add2 ins_reso                 "Ändere die Bildschirmauflösung"
_tr_add2 ins_resotip              "Ändere jetzt die Bildschirmauflösung "

# 2020-Sep-08:
_tr_add2 add_more_apps_arch          "Suche nach Archlinux Paketen"
_tr_add2 add_more_apps_aur           "Suche nach AUR Paketen"
_tr_add2 add_more_apps_done1_text    "Empfohlene Programme sind bereits installiert$_exclamation"
_tr_add2 add_more_apps_done2_text    "\n\nDu kannst auch alle Archlinux und AUR Pakete durchsuchen  (und diese dann mit dem Terminal installieren).\n"
_tr_add2 add_more_apps_done2_tip1    "Benutze 'pacman' oder 'yay' zum installieren"
_tr_add2 add_more_apps_done2_tip2    "Benutze 'yay' zum installieren."

# 2020-Sep-11:
_tr_add2 after_install_ew2      "blackarch Bildschirm-Hintergrund (Auswahl)"
_tr_add2 after_install_ewtip2   "Wähle aus den blackarch Bildschirm-Hintergründen"

# 2020-Sep-15:
#    IMPORTANT NOTE:
#       - line 71:  changed text of 'after_install_ew'
#       - line 72:  changed text of 'after_install_ewtip'
#       - line 249: changed text of 'after_install_ew2'
#       - line 250: changed text of 'after_install_ewtip2'
