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

_tr_lang=se            # required helper variable for _tr_add2

# Help with some special characters (HTML). Yad has problems without them:
_exclamation='&#33;'   # '!'
_and='&#38;'           # '&'
_question='&#63;'      # '?'
###################### Now the actual strings to be translated: ######################
# func   <placeholder>         "string"

_tr_add2 welcome_disabled      "$PRETTY_PROGNAME app är inaktiv. F&#246;r att starta den i alla fall, anv&#228;nd --enable."

_tr_add2 butt_later            "Ses senare"
_tr_add2 butt_latertip         "H&#229;ll $PRETTY_PROGNAME aktiverad"

_tr_add2 butt_noshow           "Visa inte mig igen"
_tr_add2 butt_noshowtip        "Deaktivera $PRETTY_PROGNAME"

_tr_add2 butt_help             "Hj&#228;lp"


_tr_add2 nb_tab_INSTALL        "ISTALLERA"
_tr_add2 nb_tab_GeneralInfo    "Generell information"
_tr_add2 nb_tab_AfterInstall   "Efter installationen"
_tr_add2 nb_tab_AddMoreApps    "L&#228;gg till fler appar"


_tr_add2 after_install_text    "Efterinstallations-sysslor"

_tr_add2 after_install_um      "Uppdatera speglar"
_tr_add2 after_install_umtip   "Uppdatera spegellista innan systemuppdatering"

_tr_add2 after_install_us      "Uppdatera system"
_tr_add2 after_install_ustip   "Uppdatera systemmjukvara"

_tr_add2 after_install_dsi     "Hitta systemfel"
_tr_add2 after_install_dsitip  "Hitta potentiella fel i systempaket eller n&#229;gon annanstans"

_tr_add2 after_install_etl     "blackarch senaste version$_question"
_tr_add2 after_install_etltip  "Visa hur du f&#229;r ditt system till senaste blackarch-niv&#229;"

_tr_add2 after_install_cdm     "Byt bildsk&#228;rmshanterare"
_tr_add2 after_install_cdmtip  "Anv&#228;nd en annan bildsk&#228;rmshanterare"

_tr_add2 after_install_ew      "blackarch skrivbordsbakgrund"
_tr_add2 after_install_ewtip   "&#196;ndra skrivbordsbakgrund till barch standardbakgrund"


_tr_add2 after_install_pm      "Pakethantering"
_tr_add2 after_install_pmtip   "Hur man hanterar paket med pacman"

_tr_add2 after_install_ay      "AUR $_and yay$_exclamation"
_tr_add2 after_install_aytip   "Arch User Repository och yay-information"

_tr_add2 after_install_hn      "H&#229;rdvara och nätv&#228;rk"
_tr_add2 after_install_hntip   "F&#229; din h&#229;rdvara att fungera"

_tr_add2 after_install_bt      "Bl&#229;tand"
_tr_add2 after_install_bttip   "R&#229;d ang&#229;ende bl&#229;tand"

_tr_add2 after_install_nv      "NVIDIA-anv&#228;ndare$_exclamation"
_tr_add2 after_install_nvtip   "Anv&#228;nd NVIDIA-installeraren"

_tr_add2 after_install_ft      "Forumtips"
_tr_add2 after_install_fttip   "Hj&#228;lp oss hj&#228;lpa dig!"


_tr_add2 general_info_text     "Finn din v&#228;g på blackarch hemsida$_exclamation"

_tr_add2 general_info_ws       "Hemsida"

_tr_add2 general_info_wi       "Wiki"
_tr_add2 general_info_witip    "Rekomenderade artiklar"

_tr_add2 general_info_ne       "Nyheter"
_tr_add2 general_info_netip    "Nyheter och artiklar"

_tr_add2 general_info_fo       "Forum"
_tr_add2 general_info_fotip    "Fr&#229;ga, kommentera, och chatta i vårt v&#228;nliga forum!"

_tr_add2 general_info_do       "Donera"
_tr_add2 general_info_dotip    "Hj&#228;lp oss h&#229;lla ig&#229;ng blackarch"

_tr_add2 general_info_ab       "Om $PRETTY_PROGNAME"
_tr_add2 general_info_abtip    "Mer information om denna app"


_tr_add2 add_more_apps_text    "Installera popul&#228;ra appar"

_tr_add2 add_more_apps_lotip   "Office-verktyg (libreoffice-fresh)"

_tr_add2 add_more_apps_ch      "Chromium Web-l&#228;sare"
_tr_add2 add_more_apps_chtip   "Web-l&#228;sare"

_tr_add2 add_more_apps_fw      "Brandv&#228;gg"
_tr_add2 add_more_apps_fwtip   "Gufw brandv&#228;gg"

_tr_add2 add_more_apps_bt      "Bl&#229;tand (blueberry) for Xfce"
_tr_add2 add_more_apps_bt_bm   "Bl&#229;tand (blueman) for Xfce"


####################### NEW STUFF AFTER THIS LINE:

_tr_add2 settings_dis_contents   "F&#246;r att k&#246;ra $PRETTY_PROGNAME igen, starta terminalen och k&#246;r: $PROGNAME --enable"
_tr_add2 settings_dis_text       "&#197;teraktivera $PRETTY_PROGNAME:"
_tr_add2 settings_dis_title      "Hur man &#229;teraktiverar $PRETTY_PROGNAME"
_tr_add2 settings_dis_butt       "Jag kommer ih&#229;g"
_tr_add2 settings_dis_buttip     "Jag lovar"

_tr_add2 help_butt_title         "$PRETTY_PROGNAME Hj&#228;lp"
_tr_add2 help_butt_text          "Mer information om $PRETTY_PROGNAME app"

_tr_add2 dm_title                "V&#228;lj sk&#228;rmhanterare"
_tr_add2 dm_col_name1            "Vald"
_tr_add2 dm_col_name2            "DM-namn"

_tr_add2 dm_reboot_required      "Omstart kr&#228;vs f&#246;r att f&#246;r&#228;ndringarna ska f&#229; effekt."
_tr_add2 dm_changed              "DM &#246;ndrad till: "
_tr_add2 dm_failed               "Byte av DM misslyckades."
_tr_add2 dm_warning_title        "Varning"

_tr_add2 install_installer       "Installerare"
_tr_add2 install_already         "redan installerad"
_tr_add2 install_ing             "Installering"
_tr_add2 install_done            "Klar."

_tr_add2 sysup_no                "Inga uppdateringar."
_tr_add2 sysup_check             "Letar efter mjukvaruuppdateringar..."

_tr_add2 issues_title            "Paketproblem-detektion"
_tr_add2 issues_grub             "VIKTIGT: Manuellt &#229;terskapande av bootmeny kommer att kr&#228;vas."
_tr_add2 issues_run              "K&#246;r komandon:"
_tr_add2 issues_no               "Inga viktiga systemfel uppt&#228;cktes."

_tr_add2 cal_noavail            "Icke tillg&#228;ngligt: "        # installer program
_tr_add2 cal_warn               "Varning"
_tr_add2 cal_info1              "Det h	&#228;r 	&#228;r en community development release.\n\n"                                   # specials needed!
_tr_add2 cal_info2              "<b>Offline</b> metoden ger dig en Xfce-desktop med blackarch-tema.\nInternetuppkoppling 	&#228;r inte n&#246;dv&#228;ndig.\n\n"
_tr_add2 cal_info3              "<b>Online</b> metoden l&#229;ter dig v&#228;lja skrivbordsbakgrund, med vaniljtema.\nInternetuppkoppling kr&#228;vs.\n\n"
_tr_add2 cal_info4              "OBS: Denna release &#228;r ett p&#229;g&#229;ende arbete, v&#228;nligen hj&#228;lp oss att g&#246;ra det stabilt genom att rapportera buggar\n"
_tr_add2 cal_choose             "V&#228;lj installationsmetod"
_tr_add2 cal_method             "Metod"
_tr_add2 cal_nosupport          "$PROGNAME: Icke st&#246;tt l&#228;ge: "
_tr_add2 cal_nofile             "$PROGNAME: n&#246;dv&#228;ndig fil existerar inte: "
_tr_add2 cal_istarted           "Installation startad"
_tr_add2 cal_istopped           "Installation klar"

_tr_add2 tail_butt              "St&#228;ng detta f&#246;nster"
_tr_add2 tail_buttip            "St&#228;ng bara detta f&#246;nster"


_tr_add2 ins_text              "Installerar blackarch till disk"
_tr_add2 ins_start             "Starta installereraren"
_tr_add2 ins_starttip          "Starta blackarch-installeraren tillsammans med debug terminal"
_tr_add2 ins_up                "Uppdatera denna app$_exclamation"
_tr_add2 ins_uptip             "Uppdaterar denna app och omstartar den"
_tr_add2 ins_keys              "Initiera pacman-nycklar"
_tr_add2 ins_keystip           "Initiera pacman-nycklar"
_tr_add2 ins_pm                "Partitionshanterare"
_tr_add2 ins_pmtip             "Gparted till&#229;ter unders&#246;kning and hantering av diskpartitioner and strukturer"
_tr_add2 ins_rel               "Senaste release-information"
_tr_add2 ins_reltip            "Mer information om senaste releasen"
_tr_add2 ins_tips              "Installationstips"
_tr_add2 ins_tipstip           "Installationstips"
_tr_add2 ins_trouble           "Fels&#246;k"
_tr_add2 ins_troubletip        "Systemr&#228;ddning"

_tr_add2 after_install_us_from    "Uppdateringar fr&#229;n"                            # AUR or upstream
_tr_add2 after_install_us_el      "Ut&#246;kade r&#228;ttigheter kr&#228;vs."
_tr_add2 after_install_us_done    "uppdatering f&#228;rdig."
_tr_add2 after_install_us_fail    "uppdatering misslyckades!"
