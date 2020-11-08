# Traduceri pentru aplicația Welcome.
#
# Notă: variabilele (precum $PRETTY_PROGNAME mai jos) pot fi folosite dacă sunt deja declarate
# - în aplicația Welcome
# - global
#
#
# Orice șir trebuie structurat de forma:
#
#    _tr_add <language> <placeholder> "string"
#          or
#    _tr_add2 <placeholder> "string"
#
# unde
#
#    _tr_add         O funcție bash ce adaugă un "șir" la o bază de date de șiruri
#    _tr_add2        Identic ca și _tr_add dar detectează și preia limba din variabila  _tr_lang (jos).
#    <language>      Un acronim pentru limbă de ex. "ro" pentru română (verifică variabila LANG).
#    <placeholder>   Un nume predefinit ce identifică poziția în aplicația Welcome unde șirul este folosit.
#    "string"        Șirul tradus pentru aplicația Welcome.

# Română:

### Câteva definiții ajutătoare:

_tr_lang=ro            # variabilă de ajutor necesară pentru  _tr_add2

# Ajutor cu câteva caractere special (HTML). Yad genereză probleme fără ele:
_exclamation='&#33;'   # '!'
_and='&#38;'           # '&'
_question='&#63;'      # '?'


###################### ACUM ȘIRURILE REALE CE URMEAZĂ A FI TRADUSE ######################
# func   <placeholder>           "string"

_tr_add2 welcome_disabled        "$PRETTY_PROGNAME aplicația este dezactivată.Pentru a o porni oricum, folosește opțiunea --enable."

_tr_add2 butt_later              "La revedere"
_tr_add2 butt_latertip           "Menține $PRETTY_PROGNAME activat"

_tr_add2 butt_noshow             "Nu mă mai afișa"
_tr_add2 butt_noshowtip          "Dezactivează $PRETTY_PROGNAME"

_tr_add2 butt_help               "Ajutor"


_tr_add2 nb_tab_INSTALL          "INSTALARE"
_tr_add2 nb_tab_GeneralInfo      "Informații Generale"
_tr_add2 nb_tab_AfterInstall     "După Instalare"
_tr_add2 nb_tab_AddMoreApps      "Adaugă Aplicații"


_tr_add2 after_install_text      "Sarcini după instalare"

_tr_add2 after_install_um        "Actualizează Surse"
_tr_add2 after_install_umtip     "Actualizează lista de locații de descărcare înainte de actualizarea sistemului"

_tr_add2 after_install_us        "Actualizează Sistem"
_tr_add2 after_install_ustip     "Actualizează Software Sistem"

_tr_add2 after_install_dsi       "Detectează Erori Sistem"
_tr_add2 after_install_dsitip    "Detectează orice problemă eventuală legată de pachetele sistemului sau altundeva"

_tr_add2 after_install_etl       "blackarch actualizat$_question"
_tr_add2 after_install_etltip    "Arată ce să faci să-ți pui sistemul blackarch la ultimul nivel"

_tr_add2 after_install_cdm       "Schimbă Display Manager"
_tr_add2 after_install_cdmtip    "Folosește un display manager diferit"

_tr_add2 after_install_ew        "Imagine de fundal EOS"
_tr_add2 after_install_ewtip     "Schimbă imaginea de fundal la cea predefinită de blackarch"


_tr_add2 after_install_pm        "Administrare Pachete"
_tr_add2 after_install_pmtip     "Cum să administrezi pachete cu pacman"

_tr_add2 after_install_ay        "AUR $_and yay$_exclamation"
_tr_add2 after_install_aytip     "Repertoriu Utilizator Arch  și informații despre yay"

_tr_add2 after_install_hn        "Hardware și Rețea"
_tr_add2 after_install_hntip     "Pune în stare de funcționare componentele hardware"

_tr_add2 after_install_bt        "Bluetooth"
_tr_add2 after_install_bttip     "Bluetooth advice"

_tr_add2 after_install_nv        "Utilizatori NVIDIA$_exclamation"
_tr_add2 after_install_nvtip     "Folosește instalatorul NVIDIA"

_tr_add2 after_install_ft        "Sfaturi forum"
_tr_add2 after_install_fttip     "Ajută-ne să te ajutăm$_exclamation"


_tr_add2 general_info_text       "Găsește-ți calea către site-ul blackarch$_exclamation"

_tr_add2 general_info_ws         "Site web"

_tr_add2 general_info_wi         "Wiki"
_tr_add2 general_info_witip      "Articole promovate"

_tr_add2 general_info_ne         "Știri"
_tr_add2 general_info_netip      "Știri și articole"

_tr_add2 general_info_fo         "Forum"
_tr_add2 general_info_fotip      "Întreabă, comentează și discută în forumul nostru amical$_exclamation"

_tr_add2 general_info_do         "Donează"
_tr_add2 general_info_dotip      "Ajută-ne să menținem blackarch în derulare"

_tr_add2 general_info_ab         "Despre $PRETTY_PROGNAME"
_tr_add2 general_info_abtip      "Mai multe informații despre acestă aplicație"


_tr_add2 add_more_apps_text      "Instalează aplicații populare"

_tr_add2 add_more_apps_lotip     "Instrumente suită birou (libreoffice-fresh)"

_tr_add2 add_more_apps_ch        "Chromium"
_tr_add2 add_more_apps_chtip     "Web Browser"

_tr_add2 add_more_apps_fw        "Firewall"
_tr_add2 add_more_apps_fwtip     "Gufw firewall"

_tr_add2 add_more_apps_bt        "Bluetooth (blueberry) Xfce"
_tr_add2 add_more_apps_bt_bm     "Bluetooth (blueman) Xfce"


###################### CHESTII NOI DUPĂ ACEASTĂ LINIE ######################

_tr_add2 settings_dis_contents   "Pentru a executa $PRETTY_PROGNAME din nou, deschide un terminal și rulează comanda: $PROGNAME --enable"
_tr_add2 settings_dis_text       "Re-activare $PRETTY_PROGNAME: "
_tr_add2 settings_dis_title      "Cum să re-activezi $PRETTY_PROGNAME"
_tr_add2 settings_dis_butt       "Îmi aduc aminte"
_tr_add2 settings_dis_buttip     "Promit"

_tr_add2 help_butt_title         "$PRETTY_PROGNAME Ajutor"
_tr_add2 help_butt_text          "Mai multe informații despre aplicația $PRETTY_PROGNAME"

_tr_add2 dm_title                "Selectează Display Manager"
_tr_add2 dm_col_name1            "Selectat"
_tr_add2 dm_col_name2            "Nume DM"

_tr_add2 dm_reboot_required      "O repornire este necesară pentru ca schimbările să aibe efect."
_tr_add2 dm_changed              "DM schimbat la: "
_tr_add2 dm_failed               "Schimbarea DM a eșuat."
_tr_add2 dm_warning_title        "Atenție"

_tr_add2 install_installer       "Instalatorul"
_tr_add2 install_already         "Deja instalat"
_tr_add2 install_ing             "În proces de instalare"
_tr_add2 install_done            "Terminat."

_tr_add2 sysup_no                "Nu există actualizări"
_tr_add2 sysup_check             "Verificând dacă există actualizări pentru software..."

_tr_add2 issues_title            "Detectare probleme pachete"
_tr_add2 issues_grub             "IMPORTANT: va fi necesară recrearea manuală a meniului de pornire."
_tr_add2 issues_run              "Executând comenzi: "
_tr_add2 issues_no               "Nu au fost detectate probleme importante de sistem."

_tr_add2 cal_noavail             "Indisponibil: "        					# Program de instalare
_tr_add2 cal_warn                "Atenție"
_tr_add2 cal_info1               "Aceasta este o versiune dezvoltată de către comunitate.\n\n"	# Speciale necesare!
_tr_add2 cal_info2               "<b>Offline</b>acest mod vă oferă un mediu desktop Xfce cu o temă blackarch.\nConexiunea la internet nu este necesară.\n\n"
_tr_add2 cal_info3               "<b>Online</b> acest mod vă oferă să alegeți propriul mediu desktop, cu o temă obișnuită.\nConexiunea la internet este necesară.\n\n"
_tr_add2 cal_info4               "Vă rugăm să rețineți: Această versiune este o ediție în dezvoltare, vă rugăm să ne ajutați să o facem stabilă raportând erori.\n"
_tr_add2 cal_choose              "Alege metodă de instalare"
_tr_add2 cal_method              "Metodă"
_tr_add2 cal_nosupport           "$PROGNAME: mod neacceptat: "
_tr_add2 cal_nofile              "$PROGNAME: fișierul cerut nu există: "
_tr_add2 cal_istarted            "Instalare începută"
_tr_add2 cal_istopped            "Instalare terminată"

_tr_add2 tail_butt               "Închide această fereastră"
_tr_add2 tail_buttip             "Închide doar această fereastră"


_tr_add2 ins_text                "Instalează blackarch pe disc"
_tr_add2 ins_start               "Pornește instalatorul"
_tr_add2 ins_starttip            "Pornește instalatorul blackarch însoțit de un terminal de depanare"
_tr_add2 ins_up                  "Actualizează această aplicație$_exclamation"
_tr_add2 ins_uptip               "Actualizează această aplicație și o repornește"
_tr_add2 ins_keys                "Inițializeză chei pacman"
_tr_add2 ins_keystip             "Inițializeză chei pacman"
_tr_add2 ins_pm                  "Administrator de partiții"
_tr_add2 ins_pmtip               "Gparted permite examinarea și administrarea structurii discului și a partițiilor"
_tr_add2 ins_rel                 "Informații despre ultima versiune"
_tr_add2 ins_reltip              "Mai multe informații despre ultima versiune"
_tr_add2 ins_tips                "Sfaturi pentru instalare"
_tr_add2 ins_tipstip             "Sfaturi pentru instalare"
_tr_add2 ins_trouble             "Depanare"
_tr_add2 ins_troubletip          "Salvare Sistem"

_tr_add2 after_install_us_from   "Actualizari de la"                            		# AUR sau upstream
_tr_add2 after_install_us_el     "Sunt necesare privilegii ridicate."
_tr_add2 after_install_us_done   "Actualizare terminată."
_tr_add2 after_install_us_fail   "Actualizare eșuată$_exclamation"
