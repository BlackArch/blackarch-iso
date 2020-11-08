# Preklad aplikácie Welcome.
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

_tr_lang=sk            # required helper variable for _tr_add2

# Help with some special characters (HTML). Yad has problems without them:
_exclamation='&#33;'   # '!'
_and='&#38;'           # '&'
_question='&#63;'      # '?'


###################### Now the actual strings to be translated: ######################
# func   <placeholder>         "string"

_tr_add2 welcome_disabled      "Aplikácia $PRETTY_PROGNAME je zakázaná. Ak sa má napriek tomu spustiť, použite voľbu --enable."

_tr_add2 butt_later            "Uvidíme sa neskôr"
_tr_add2 butt_latertip         "Ponechá aplikáciu $PRETTY_PROGNAME povolenú"

_tr_add2 butt_noshow           "Už viac nezobrazovať"
_tr_add2 butt_noshowtip        "Zakáže aplikáciu $PRETTY_PROGNAME"

_tr_add2 butt_help             "Pomocník"


_tr_add2 nb_tab_INSTALL        "INŠTALÁCIA"
_tr_add2 nb_tab_GeneralInfo    "Všeobecné informácie"
_tr_add2 nb_tab_AfterInstall   "Po inštalácii"
_tr_add2 nb_tab_AddMoreApps    "Pridanie ďalších aplikácií"


_tr_add2 after_install_text    "Úlohy po nainštalovaní"

_tr_add2 after_install_um      "Aktualizovať zrkadlá"
_tr_add2 after_install_umtip   "Vykoná aktualizáciu zoznamu zrkadiel pred aktualizáciou systému"

_tr_add2 after_install_us      "Aktualizovať systém"
_tr_add2 after_install_ustip   "Vykoná aktualizáciu systémového softvéru"

_tr_add2 after_install_dsi     "Zistiť problémy so systémom"
_tr_add2 after_install_dsitip  "Zistí akékoľvek možné problémy so systémovými balíkmi alebo s čímkoľvek iným"

_tr_add2 after_install_etl     "Najnovší systém blackarch$_question"
_tr_add2 after_install_etltip  "Zobrazí, ako dostať váš systém blackarch na najnovšiu úroveň"

_tr_add2 after_install_cdm     "Zmeniť správcu zobrazenia"
_tr_add2 after_install_cdmtip  "Použije iného správcu zobrazenia"

_tr_add2 after_install_ew      "Východzie pozadie systému blackarch"
_tr_add2 after_install_ewtip   "Navrátiť pozadie na východzie"


_tr_add2 after_install_pm      "Správa balíkov"
_tr_add2 after_install_pmtip   "Ako spravovať balíky pomocou aplikácie pacman"

_tr_add2 after_install_ay      "Repozitár AUR a nástroj yay$_exclamation"
_tr_add2 after_install_aytip   "Informácie o užívateľskom repozitári systému Arch a nástroji yay"

_tr_add2 after_install_hn      "Hardvér a sieť"
_tr_add2 after_install_hntip   "Urobte váš hardvér funkčným"

_tr_add2 after_install_bt      "Bluetooth"
_tr_add2 after_install_bttip   "Rada k pripojeniu Bluetooth"

_tr_add2 after_install_nv      "Používatelia grafických kariet NVIDIA$_exclamation"
_tr_add2 after_install_nvtip   "Použitie inštalátora grafických kariet NVIDIA"

_tr_add2 after_install_ft      "Rady k fóru"
_tr_add2 after_install_fttip   "Pomôžte nám, my pomôžeme vám!"


_tr_add2 general_info_text     "Nájdite svoju cestu na webovej stránke systému blackarch$_exclamation"

_tr_add2 general_info_ws       "Webová stránka"

_tr_add2 general_info_wi       "Wiki"
_tr_add2 general_info_witip    "Vybrané články"

_tr_add2 general_info_ne       "Novinky"
_tr_add2 general_info_netip    "Novinky a články"

_tr_add2 general_info_fo       "Fórum"
_tr_add2 general_info_fotip    "Pýtajte sa, komentujte a rozprávajte sa v našom priateľskom fóre!"

_tr_add2 general_info_do       "Prispieť"
_tr_add2 general_info_dotip    "Pomôžte nám v zachovaní chodu systému blackarch"

_tr_add2 general_info_ab       "O aplikácii $PRETTY_PROGNAME"
_tr_add2 general_info_abtip    "Viac informácií o tejto aplikácii"


_tr_add2 add_more_apps_text    "Nainštalujte obľúbené aplikácie"

_tr_add2 add_more_apps_lotip   "Kancelárske nástroje (libreoffice-fresh)"

_tr_add2 add_more_apps_ch      "Webový prehliadač Chromium"
_tr_add2 add_more_apps_chtip   "Webový prehliadač"

_tr_add2 add_more_apps_fw      "Brána Firewall"
_tr_add2 add_more_apps_fwtip   "Nástroj brány firewall Gufw"

_tr_add2 add_more_apps_bt      "Bluetooth (blueberry) pre prostredie Xfce"
_tr_add2 add_more_apps_bt_bm   "Bluetooth (blueman) pre prostredie Xfce"


####################### NEW STUFF AFTER THIS LINE:

_tr_add2 settings_dis_contents   "Na opätovné spustenie aplikácie $PRETTY_PROGNAME otvorte terminál a spustite: $PROGNAME --enable"
_tr_add2 settings_dis_text       "Opätovné povolenie aplikácie $PRETTY_PROGNAME:"
_tr_add2 settings_dis_title      "Ako znovu povoliť aplikáciu $PRETTY_PROGNAME"
_tr_add2 settings_dis_butt       "Zapamätám si"
_tr_add2 settings_dis_buttip     "Sľubujem"

_tr_add2 help_butt_title         "Pomocník aplikácie $PRETTY_PROGNAME"
_tr_add2 help_butt_text          "Viac informácií o aplikácii $PRETTY_PROGNAME"

_tr_add2 dm_title                "Výber správcu zobrazenia"
_tr_add2 dm_col_name1            "Vybraný"
_tr_add2 dm_col_name2            "Názov správcu zobrazenia"

_tr_add2 dm_reboot_required      "Na uplatnenie zmien je potrebný reštart."
_tr_add2 dm_changed              "Správca zobrazenia bol zmenený na: "
_tr_add2 dm_failed               "Zmena správcu zobrazenia zlyhala."
_tr_add2 dm_warning_title        "Upozornenie"

_tr_add2 install_installer       "Inštalátor"
_tr_add2 install_already         "už je nainštalovaný"
_tr_add2 install_ing             "Inštaluje sa"
_tr_add2 install_done            "Dokončené."

_tr_add2 sysup_no                "Žiadne aktualizácie."
_tr_add2 sysup_check             "Kontrolujú sa aktualizácie softvéru..."

_tr_add2 issues_title            "Zisťovanie problémov s balíkmi"
_tr_add2 issues_grub             "DÔLEŽITÉ: bude potrebné opätovné ručné vytvorenie zavádzacej ponuky."
_tr_add2 issues_run              "Spúšťajú sa príkazy:"
_tr_add2 issues_no               "Neboli zistené žiadne závažné problémy so systémom."

_tr_add2 cal_noavail            "Nedostupný: "        # installer program
_tr_add2 cal_warn               "Upozornenie"
_tr_add2 cal_info1              "Toto je komunitné vývojové vydanie.\n\n"                                   # specials needed!
_tr_add2 cal_info2              "Spôsob <b>Bez pripojenia</b> vám poskytne pracovné prostredie Xfce s motívom systému blackarch.\nInternetové pripojenie nie je potrebné.\n\n"
_tr_add2 cal_info3              "Spôsob <b>S pripojením</b> vám umožní zvoliť pracovné prostredie s pôvodným čistím motívom.\nInternetové pripojenie je potrebné.\n\n"
_tr_add2 cal_info4              "Poznámka: Na tomto vydaní sa stále pracuje. Prosím, pomôžte nám vytvoriť stabilné vydanie pomocou nahlásenia chýb.\n"
_tr_add2 cal_choose             "Zvoľte spôsob inštalácie"
_tr_add2 cal_method             "Spôsob"
_tr_add2 cal_nosupport          "$PROGNAME: nepodporovaný režim: "
_tr_add2 cal_nofile             "$PROGNAME: požadovaný súbor neexistuje: "
_tr_add2 cal_istarted           "Inštalácia bola spustená"
_tr_add2 cal_istopped           "Inštalácia bola dokončená"

_tr_add2 tail_butt              "Zavrieť toto okno"
_tr_add2 tail_buttip            "Zavrie iba toto okno"


_tr_add2 ins_text              "Inštaluje sa systém blackarch na disk"
_tr_add2 ins_start             "Spustiť inštalátor"
_tr_add2 ins_starttip          "Spustí inštalátor systému blackarch spolu s ladiacim terminálom"
_tr_add2 ins_up                "Aktualizovať túto aplikáciu$_exclamation"
_tr_add2 ins_uptip             "Vykoná aktualizáciu tejto aplikácie a znovu ju spustí"
_tr_add2 ins_keys              "Inicializovať kľúče aplikácie pacman"
_tr_add2 ins_keystip           "Vykoná inicializáciu kľúčov aplikácie pacman"
_tr_add2 ins_pm                "Správca oddielov"
_tr_add2 ins_pmtip             "Aplikácia Gparted vám umožní preskúmať a spravovať oddiely na diskoch a ich štruktúru"
_tr_add2 ins_rel               "Informácie o najnovšom vydaní"
_tr_add2 ins_reltip            "Viac informácií o najnovšom vydaní"
_tr_add2 ins_tips              "Rady k inštalácii"
_tr_add2 ins_tipstip           "Zobrazí rady k inštalácii"
_tr_add2 ins_trouble           "Riešiť problémy"
_tr_add2 ins_troubletip        "Záchrana systému"

_tr_add2 after_install_us_from    "Aktualizácie z repozitára"                            # AUR or upstream
_tr_add2 after_install_us_el      "Vyžadujú sa vyvýšené práva."
_tr_add2 after_install_us_done    "aktualizácia dokončená."
_tr_add2 after_install_us_fail    "aktualizácia zlyhala!"

# 2020-May-14:

_tr_add2 nb_tab_UsefulTips     "Rady"
_tr_add2 useful_tips_text      "Užitočné rady"

# 2020-May-16:

_tr_add2 butt_changelog        "Zoznam zmien"
_tr_add2 butt_changelogtip     "Ukázať zoznam zmien v uvítacej aplikácii"

_tr_add2 after_install_themevan      "Čistý Xfce vzhľad"
_tr_add2 after_install_themevantip   "Použiť čistý vzhľad Xfce"

_tr_add2 after_install_themedef     "Endeavour OS vzhľad pre Xfce"
_tr_add2 after_install_themedeftip  "Použiť blackarch vzhľad pre Xfce"

# 2020-Jun-28:
_tr_add2 after_install_pclean       "Nastavenie prečisťovania balíčkov"
_tr_add2 after_install_pcleantip    "Nastavte službu prečisťovania vyrovnávacej pamäte balíčkov"

# 2020-Jul-04:
_tr_add2 nb_tab_OwnCommands         "Vlastné príkazy"                       # modified 2020-Jul-08
_tr_add2 nb_tab_owncmds_text        "Sebe uspôsobené príkazy"               # modified 2020-Jul-08

# 2020-Jul-08:
_tr_add2 nb_tab_owncmdstip          "Pomoc s pridávaním vlastných príkazov"

_tr_add2 add_more_apps_akm          "Správca jadra"
_tr_add2 add_more_apps_akmtip       "Malý zdroj informácií o, a správca linuxového jadra"

# 2020-Jul-15:
_tr_add2 butt_owncmds_help          "Návod: Vlastné príkazy"

# 2020-Aug-05:
_tr_add2 butt_owncmds_dnd         "Chyťte ${_and} pretiahnite vlastné príkazy"
_tr_add2 butt_owncmds_dnd_help    "Zobraziť okno, do ktorého sa dajú pretiahnúť položky na nové tlačítka"

# 2020-Sep-03:
_tr_add2 ins_reso                 "Zmeniť rozlíšenie displeja"
_tr_add2 ins_resotip              "Teraz zmeniť rozlíšenie displeja"

# 2020-Sep-08:
_tr_add2 add_more_apps_arch       "Prehľadávať medzi všetkými Arch balíkmi"
_tr_add2 add_more_apps_aur        "Prehľadávať medzi všetkými AUR balíkmi"
_tr_add2 add_more_apps_done1_text "Navrhované balíky sú už nainštalované$_exclamation"
_tr_add2 add_more_apps_done2_text "\n\nMôžete tiež prehliadať všetky Arch a AUR balíky (a inštalovať ich pomocou terminálu).\n"      
_tr_add2 add_more_apps_done2_tip1    "Pre inštaláciu použite 'pacman', alebo 'yay'"     
_tr_add2 add_more_apps_done2_tip2    "Pre inštaláciu použite 'yay'"

# 2020-Sep-11:      
_tr_add2 after_install_ew2        "Výber jedného z pozadí blackarch"   # was: "blackarch wallpaper (choose)"   
_tr_add2 after_install_ewtip2     "Výber pozadí"                         # was: "Choose from blackarch default wallpapers"

# 2020-Sep-15:
#    IMPORTANT NOTE:
#       - line 71:  changed text of 'after_install_ew'
#       - line 72:  changed text of 'after_install_ewtip'
#       - line 249: changed text of 'after_install_ew2'
#       - line 250: changed text of 'after_install_ewtip2'
