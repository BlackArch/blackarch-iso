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

# Italiano:

### First some useful definitions:

_tr_lang=it            # required helper variable for _tr_add2

# Help with some special characters (HTML). Yad has problems without them:
_exclamation='&#33;'   # '!'
_and='&#38;'           # '&'
_question='&#63;'      # '?'


###################### ORA LE STRINGHE EFFETTIVE DA TRADURRE ######################
# func   <placeholder>            "string"

_tr_add2 welcome_disabled         "$PRETTY_PROGNAME l'app è disabilitata. Per avviarlo comunque, usa l'opzione --enable."

_tr_add2 butt_later               "Arrivederci"
_tr_add2 butt_latertip            "Mantenere $PRETTY_PROGNAME abilitata"

_tr_add2 butt_noshow              "Non mostrarmi più"
_tr_add2 butt_noshowtip           "Disabilita $PRETTY_PROGNAME"

_tr_add2 butt_help                "Aiuto"


_tr_add2 nb_tab_INSTALL           "Installazione"
_tr_add2 nb_tab_GeneralInfo       "Informazioni Generali"
_tr_add2 nb_tab_AfterInstall      "Dopo Installazione"
_tr_add2 nb_tab_AddMoreApps       "Aggiungi altre App"


_tr_add2 after_install_text       "Dopo le attività di installazione"

_tr_add2 after_install_um         "Aggiorna i Mirrors"
_tr_add2 after_install_umtip      "Aggiorna l'elenco dei mirror prima dell'aggiornamento del sistema"

_tr_add2 after_install_us         "Aggiornamento Sistema"
_tr_add2 after_install_ustip      "Aggiorna software di sistema"

_tr_add2 after_install_dsi        "Rileva errore Sistema"
_tr_add2 after_install_dsitip     "Rileva eventuali problemi sui pacchetti di sistema o altrove"

_tr_add2 after_install_etl        "blackarch ultimo$_question"
_tr_add2 after_install_etltip     "Mostra cosa fare per portare il tuo sistema all'ultimo livello di blackarch"

_tr_add2 after_install_cdm        "Cambia Display Manager"
_tr_add2 after_install_cdmtip     "Utilizzare un display manager diverso"

_tr_add2 after_install_ew         "blackarch sfondi"
_tr_add2 after_install_ewtip      "Cambia lo sfondo del desktop con l'impostazione predefinita barch"


_tr_add2 after_install_pm         "Gestione Pacchetti"
_tr_add2 after_install_pmtip      "Come gestire i pacchetti con pacman"

_tr_add2 after_install_ay         "AUR $_and yay$_exclamation"
_tr_add2 after_install_aytip      "Arch User Repository e informazioni su yay"

_tr_add2 after_install_hn         "Hardware e Rete"
_tr_add2 after_install_hntip      "Fai funzionare il tuo hardware"

_tr_add2 after_install_bt         "Bluetooth"
_tr_add2 after_install_bttip      "Consigli sul bluetooth"

_tr_add2 after_install_nv         "Utenti NVIDIA$_exclamation"
_tr_add2 after_install_nvtip      "Utilizzare il programma di installazione NVIDIA"

_tr_add2 after_install_ft         "Suggerimenti Forum"
_tr_add2 after_install_fttip      "Aiutaci ad aiutarti$_exclamation"


_tr_add2 general_info_text        "Trova la tua strada sul sito web di blackarch$_exclamation"

_tr_add2 general_info_ws          "Sito web"

_tr_add2 general_info_wi          "Wiki"
_tr_add2 general_info_witip       "Articoli in vetrina"

_tr_add2 general_info_ne          "Notizie"
_tr_add2 general_info_netip       "Notizie e articoli"

_tr_add2 general_info_fo          "Forum"
_tr_add2 general_info_fotip       "Chiedi, commenta e chatta nel nostro amichevole forum$_exclamation"

_tr_add2 general_info_do          "Donazione"
_tr_add2 general_info_dotip       "Aiutaci a far funzionare blackarch"

_tr_add2 general_info_ab          "About $PRETTY_PROGNAME"
_tr_add2 general_info_abtip       "Maggiori informazioni su questa app"


_tr_add2 add_more_apps_text       "Installa app popolari"

_tr_add2 add_more_apps_lotip      "Strumenti di Office (libreoffice-fresh)"

_tr_add2 add_more_apps_ch         "Chromium"
_tr_add2 add_more_apps_chtip      "Web Browser"

_tr_add2 add_more_apps_fw         "Firewall"
_tr_add2 add_more_apps_fwtip      "Gufw firewall"

_tr_add2 add_more_apps_bt         "Bluetooth (blueberry) per Xfce"
_tr_add2 add_more_apps_bt_bm      "Bluetooth (blueman) per Xfce"


###################### ROBA NUOVA DOPO QUESTA LINEA ######################

_tr_add2 settings_dis_contents    "Per eseguire nuovamente $PRETTY_PROGNAME, avviare un terminale ed eseguire: $PROGNAME --enable"
_tr_add2 settings_dis_text        "Riattivazione $PRETTY_PROGNAME:"
_tr_add2 settings_dis_title       "Come riattivare $PRETTY_PROGNAME"
_tr_add2 settings_dis_butt        "Io ricordo"
_tr_add2 settings_dis_buttip      "lo prometto"

_tr_add2 help_butt_title          "$PRETTY_PROGNAME Aiuto"
_tr_add2 help_butt_text           "Maggiori informazioni su $PRETTY_PROGNAME app"

_tr_add2 dm_title                 "Seleziona Display Manager"
_tr_add2 dm_col_name1             "Seleziona"
_tr_add2 dm_col_name2             "Nome DM"

_tr_add2 dm_reboot_required       "È necessario riavviare per rendere effettive le modifiche."
_tr_add2 dm_changed               "DM modificato in: "
_tr_add2 dm_failed                "Modifica DM non riuscita."
_tr_add2 dm_warning_title         "Attenzione"

_tr_add2 install_installer        "Installer"
_tr_add2 install_already          "Già installato"
_tr_add2 install_ing              "Installazione"
_tr_add2 install_done             "Finito."

_tr_add2 sysup_no                 "Nessun aggiornamento."
_tr_add2 sysup_check              "Verifica aggiornamenti software..."

_tr_add2 issues_title             "Rilevamento dei problemi del pacchetto"
_tr_add2 issues_grub              "IMPORTANTE: sarà necessario ricreare manualmente il menu di avvio."
_tr_add2 issues_run               "Esecuzione di comandi:"
_tr_add2 issues_no                "Non sono stati rilevati problemi di sistema importanti."

_tr_add2 cal_noavail              "Non disponibile: "        					# installer program
_tr_add2 cal_warn                 "Attenzione"
_tr_add2 cal_info1                "Questa è una versione di sviluppo della comunità.\n\n"	# specials needed!
_tr_add2 cal_info2                "<b>Offline</b> Il metodo offre un desktop Xfce con temi blackarch.\nNon è necessaria la connessione a Internet.\n\n"
_tr_add2 cal_info3                "<b>Online</b> Il metodo ti consente di scegliere il tuo desktop, con temi standard.\nÈ richiesta una connessione a Internet.\n\n"
_tr_add2 cal_info4                "Nota: questa versione è un work-in-progress, ti preghiamo di aiutarci a renderlo stabile segnalando i bug.\n"
_tr_add2 cal_choose               "Scegli il metodo di installazione"
_tr_add2 cal_method               "Metodo"
_tr_add2 cal_nosupport            "$PROGNAME: modalità non supportata: "
_tr_add2 cal_nofile               "$PROGNAME: il file richiesto non esiste: "
_tr_add2 cal_istarted             "Installazione avviata"
_tr_add2 cal_istopped             "Installazione completata"

_tr_add2 tail_butt                "Chiudi questa finestra"
_tr_add2 tail_buttip              "Chiudi solo questa finestra"


_tr_add2 ins_text                 "Installazione di blackarch su disco"
_tr_add2 ins_start                "Avviare il programma di installazione"
_tr_add2 ins_starttip             "Avviare il programma di installazione di blackarch insieme a un terminale di debug"
_tr_add2 ins_up                   "Aggiorna questa app$_exclamation"
_tr_add2 ins_uptip                "Aggiorna questa app e la riavvia"
_tr_add2 ins_keys                 "Inizializza le key di pacman"
_tr_add2 ins_keystip              "Inizializza le key di pacman"
_tr_add2 ins_pm                   "Gestisci le partizioni"
_tr_add2 ins_pmtip                "Gparted consente di esaminare e gestire le partizioni e la struttura del disco"
_tr_add2 ins_rel                  "Informazioni sulla versione più recente"
_tr_add2 ins_reltip               "Maggiori informazioni sull'ultima versione"
_tr_add2 ins_tips                 "Suggerimenti per l'installazione"
_tr_add2 ins_tipstip              "Suggerimenti per l'installazione"
_tr_add2 ins_trouble              "Risoluzione dei problemi"
_tr_add2 ins_troubletip           "System Rescue"

_tr_add2 after_install_us_from    "Aggiornamenti da"                            		# AUR or upstream
_tr_add2 after_install_us_el      "Sono richiesti privilegi elevati."
_tr_add2 after_install_us_done    "Aggiornamento fatto."
_tr_add2 after_install_us_fail    "Aggiornamento non riuscito$_exclamation"
