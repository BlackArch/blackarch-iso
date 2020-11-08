# Tłumaczenie wniosku Welcome
#
# Note : variables (like $PRETTY_PROGNAME below) may be used if they are already defined either
# - in the Welcome app
# - globally
#
#
# Any string should be defined like :
#
#    _tr_add <language> <placeholder> "string"
#          or
#    _tr_add2 <placeholder> "string"
#
# where
#
#    _tr_add         A bash function that adds a "string" to the strings database.
#    _tr_add2        Same as _tr_add but knows the language from the _tr_lang variable (below).
#    <language>      An acronym for the language, e.g. "en" for English (check the LANG variable !).
#    <placeholder>   A pre-defined name that identifies the place in the Welcome app where this string is used.
#    "string"        The translated string for the Welcome app.

# Polish :

### First some useful definitions :

_tr_lang=pl            # required helper variable for _tr_add2

# Help with some special characters (HTML). Yad has problems without them :
_exclamation='&#33;'   # '!'
_and='&#38;'           # '&'
_question='&#63;'      # '?'


###################### TERAZ FAKTYCZNE SZNURKI DO PRZETŁUMACZENIA ######################
# func   <placeholder>           "string"

_tr_add2 welcome_disabled        "$PRETTY_PROGNAME jest zablokowana. Aby ją uruchomić użyj opcji --enable."

_tr_add2 butt_later              "Do zobaczenia$_exclamation"
_tr_add2 butt_latertip           "Zostaw $PRETTY_PROGNAME odblokowaną"

_tr_add2 butt_noshow             "Nie pokazuj mnie więcej"
_tr_add2 butt_noshowtip          "Zablokuj $PRETTY_PROGNAME"

_tr_add2 butt_help               "Pomoc"


_tr_add2 nb_tab_INSTALL          "INSTALACJA"
_tr_add2 nb_tab_GeneralInfo      "Informacje ogólne"
_tr_add2 nb_tab_AfterInstall     "Po instalacji"
_tr_add2 nb_tab_AddMoreApps      "Dodaj aplikacje"


_tr_add2 after_install_text      "Zadania po instalacji"

_tr_add2 after_install_um        "Zaktualizuj serwery lustrzane"
_tr_add2 after_install_umtip     "Zaktualizuj listę serwerów lustrzanych przed aktualizacją systemu"

_tr_add2 after_install_us        "Zaktualizuj System"
_tr_add2 after_install_ustip     "Zaktualizuj oprogramowanie systemu"

_tr_add2 after_install_dsi       "Wykryj problemy z systemem"
_tr_add2 after_install_dsitip    "Wykryj potencjalne problemy z pakietami systemowymi lub inne"

_tr_add2 after_install_etl       "Najświeższy blackarch$_question"
_tr_add2 after_install_etltip    "Pokaż co zrobić aby podnieść Twój system do ostatniej wersji blackarch"

_tr_add2 after_install_cdm       "Zmień menedżer wyświetlania"
_tr_add2 after_install_cdmtip    "Użyj innego menedżera wyświetlania"

_tr_add2 after_install_ew        "Tapeta blackarch"
_tr_add2 after_install_ewtip     "Zmień tło pulpitu na domyślne blackarch"


_tr_add2 after_install_pm        "Zarządzanie pakietami"
_tr_add2 after_install_pmtip     "Jak zarządzać pakietami z pacmanem"

_tr_add2 after_install_ay        "AUR $_and yay $_exclamation"
_tr_add2 after_install_aytip     "Informacje o Repozytorium Użytkowników Archa oraz yay"

_tr_add2 after_install_hn        "Sprzęt i Sieć"
_tr_add2 after_install_hntip     "Uruchum swój sprzęt"

_tr_add2 after_install_bt        "Bluetooth"
_tr_add2 after_install_bttip     "Porady Bluetooth"

_tr_add2 after_install_nv        "Użytkownicy NVIDIA$_exclamation"
_tr_add2 after_install_nvtip     "Użyj instalatora NVIDIA"

_tr_add2 after_install_ft        "Wskazówki do forum"
_tr_add2 after_install_fttip     "Pomóż nam pomóc sobie$_exclamation"


_tr_add2 general_info_text       "Znajdź swoją drogę na stronę blackarch$_exclamation"

_tr_add2 general_info_ws         "Strona internetowa"

_tr_add2 general_info_wi         "Wiki"
_tr_add2 general_info_witip      "Polecane artykuły"

_tr_add2 general_info_ne         "Nowości"
_tr_add2 general_info_netip      "Nowości i artykuły"

_tr_add2 general_info_fo         "Forum"
_tr_add2 general_info_fotip      "Pytaj, komentuj i czatuj w naszym przyjaznym forum$_exclamation"

_tr_add2 general_info_do         "Wpłać darowiznę"
_tr_add2 general_info_dotip      "Pomóż nam utrzymywać blackarch"

_tr_add2 general_info_ab         "O $PRETTY_PROGNAME"
_tr_add2 general_info_abtip      "Więcej informacji o tej aplikacji"


_tr_add2 add_more_apps_text      "Zainstaluj popularne aplikacje"

_tr_add2 add_more_apps_lotip     "Narzędzia biurowe (libreoffice-fresh)"

_tr_add2 add_more_apps_ch        "Chromium"
_tr_add2 add_more_apps_chtip     "Przeglądarka internetowa Chromium"

_tr_add2 add_more_apps_fw        "Zapora sieciowa"
_tr_add2 add_more_apps_fwtip     "Gufw firewall"

_tr_add2 add_more_apps_bt        "Bluetooth (blueberry) Xfce"
_tr_add2 add_more_apps_bt_bm     "Bluetooth (blueman) Xfce"


####################### NOWE RZECZY PO TEJ LINII ######################

_tr_add2 settings_dis_contents   "Aby uruchomić $PRETTY_PROGNAME ponownie, uruchom terminal i wpisz : $PROGNAME --enable"
_tr_add2 settings_dis_text       "Odblokowuję $PRETTY_PROGNAME :"
_tr_add2 settings_dis_title      "Jak odblokować $PRETTY_PROGNAME"
_tr_add2 settings_dis_butt       "Pamiętam"
_tr_add2 settings_dis_buttip     "Obiecuję"

_tr_add2 help_butt_title         "$PRETTY_PROGNAME Pomoc"
_tr_add2 help_butt_text          "Więcej informacji o $PRETTY_PROGNAME"

_tr_add2 dm_title                "Wybierz menedżer wyświetlania"
_tr_add2 dm_col_name1            "Wybrano"
_tr_add2 dm_col_name2            "Nazwa menedżera"

_tr_add2 dm_reboot_required      "Restart jest wymagany aby zmiany zostały wprowadzone"
_tr_add2 dm_changed              "Mendżer wyświetlania zmieniony na :"
_tr_add2 dm_failed               "Zmiana Menedżera się nie powiodła"
_tr_add2 dm_warning_title        "Uwaga"

_tr_add2 install_installer       "Instalator"
_tr_add2 install_already         "Już zinstalowane"
_tr_add2 install_ing             "Instaluję"
_tr_add2 install_done            "Zakończono"

_tr_add2 sysup_no                "Brak aktualizacji."
_tr_add2 sysup_check             "Sprawdzam aktualizacje..."

_tr_add2 issues_title            "Wykrywanie problemów z pakietami"
_tr_add2 issues_grub             "WAŻNE : wymagane ręczne odtworzenie menu bootowania."
_tr_add2 issues_run              "Uruchomiam polecenia :"
_tr_add2 issues_no               "Nie wykryto istotnych błędów w systemie."

_tr_add2 cal_noavail             "Nie dostępne : "        # program nastawczy
_tr_add2 cal_warn                "Uwaga"
_tr_add2 cal_info1               "To jest deweloperskie wydanie społeczności.\n\n"		# unikalne potrzeby !
_tr_add2 cal_info2               "<b>Offline</b> Metoda Offline oferuje Ci pulpit XFCE z motywami blackarch.\nPołącznie z internetem nie jest wymagane.\n\n"
_tr_add2 cal_info3               "<b>Online</b> Metoda Online pozwala Ci wybrać pulpit z minimalnym motywem.\nPołączenie z internetem jest wymagane.\n\n"
_tr_add2 cal_info4               "Zwróć uwagę : prace nad tym wydaniem nadal trwają, pomóż nam je poprawić zgłaszając błędy.\n"
_tr_add2 cal_choose              "Wybierz metodę instalacji"
_tr_add2 cal_method              "Metoda"
_tr_add2 cal_nosupport           "$PROGNAME : tryb nie jest wspierany : "
_tr_add2 cal_nofile              "$PROGNAME : wymagany plik nie istnieje : "
_tr_add2 cal_istarted            "Instalacja rozpoczęta"
_tr_add2 cal_istopped            "Instalacja zakończona"

_tr_add2 tail_butt               "Zamknij to okno"
_tr_add2 tail_buttip             "Zamknij tylko to okno"


_tr_add2 ins_text                "Instaluję blackarch"
_tr_add2 ins_start               "Rozpocznij instalację"
_tr_add2 ins_starttip            "Rozpocznij instalację EndeacourOS z terminalem debugowania"
_tr_add2 ins_up                  "Zaktualizuj tę aplikację$_exclamation"
_tr_add2 ins_uptip               "Aktualizuj tę aplikację i uruchamia ją ponownie"
_tr_add2 ins_keys                "Inicjalizuj klucze pacmana"
_tr_add2 ins_keystip             "Inicjalizuj klucze pacmana"
_tr_add2 ins_pm                  "Menedżer partycji"
_tr_add2 ins_pmtip               "Gparted pozwala sprawdzać oraz modyfikować partycje i strukturę dysku"
_tr_add2 ins_rel                 "Informacje o ostatnim wydaniu"
_tr_add2 ins_reltip              "Więcej informacji o ostatnim wydaniu"
_tr_add2 ins_tips                "Wskazówki instalacyjne"
_tr_add2 ins_tipstip             "Wskazówki instalacyjne"
_tr_add2 ins_trouble             "Rozwiązywanie problemów"
_tr_add2 ins_troubletip          "Ratowanie systemu"

_tr_add2 after_install_us_from   "Aktualizacje od"                            # AUR lub w górę rzeki
_tr_add2 after_install_us_el     "Wymagane zwiększone uprawnienia."
_tr_add2 after_install_us_done   "Aktualizacja zakończona."
_tr_add2 after_install_us_fail   "Aktualizajca się nie powiodła$_exclamation"
