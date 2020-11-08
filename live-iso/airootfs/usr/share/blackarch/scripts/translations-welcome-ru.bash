# Переводы для Welcome заявка
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

# Russian:

### First some useful definitions:

_tr_lang=ru            # required helper variable for _tr_add2

# Help with some special characters (HTML). Yad has problems without them:
_exclamation='&#33;'   # '!'
_and='&#38;'           # '&'
_question='&#63;'      # '?'


###################### ТЕПЕРЬ ФАКТИЧЕСКИЕ СТРОКИ, КОТОРЫЕ ДОЛЖНЫ БЫТЬ ПЕРЕВЕДЕНЫ ######################
# func   <placeholder>             "string"

_tr_add2 welcome_disabled          "$PRETTY_PROGNAME отключено. Для повторного запуска используйте команду barch-welcome --enable"

_tr_add2 butt_later                "Закрыть это окно"
_tr_add2 butt_latertip             "Запускать $PRETTY_PROGNAME при старте системы"

_tr_add2 butt_noshow               "Больше не показывать"
_tr_add2 butt_noshowtip            "Отключает автозапуск $PRETTY_PROGNAME, ручной запуск сохраняется"

_tr_add2 butt_help                 "Помощь"


_tr_add2 nb_tab_INSTALL            "Установка"
_tr_add2 nb_tab_GeneralInfo        "Информация"
_tr_add2 nb_tab_AfterInstall       "После установки"
_tr_add2 nb_tab_AddMoreApps        "Установка программ"


_tr_add2 after_install_text        "Действия после установки"

_tr_add2 after_install_um          "Обновить зеркала"
_tr_add2 after_install_umtip       "Обновление списка зеркал перед обновлением системы"

_tr_add2 after_install_us          "Обновить систему"
_tr_add2 after_install_ustip       "Обновление системных модулей и программ"

_tr_add2 after_install_dsi         "Поиск ошибок"
_tr_add2 after_install_dsitip      "Обнаружение любых потенциальных проблем в системе и программах"

_tr_add2 after_install_etl         "Обновить blackarch-lightweight$_question"
_tr_add2 after_install_etltip      "Переход на следующий уровень blackarch-lightweight"

_tr_add2 after_install_cdm         "Изменить Display Manager"
_tr_add2 after_install_cdmtip      "Установка другого Display Manager"

_tr_add2 after_install_ew          "Обои blackarch-lightweight"
_tr_add2 after_install_ewtip       "Установить обои blackarch-lightweight по умолчанию"


_tr_add2 after_install_pm          "Управление пакетами"
_tr_add2 after_install_pmtip       "Как управлять пакетами с помощью pacman"

_tr_add2 after_install_ay          "AUR и yay"
_tr_add2 after_install_aytip       "Информация об Arch User Repository (AUR) и yay"

_tr_add2 after_install_hn          "Оборудование и сеть"
_tr_add2 after_install_hntip       "Заставь работать своё оборудование"

_tr_add2 after_install_bt          "Bluetooth"
_tr_add2 after_install_bttip       "Советы по использованию Bluetooth"

_tr_add2 after_install_nv          "Пользователям NVIDIA"
_tr_add2 after_install_nvtip       "Работа с NVIDIA installer"

_tr_add2 after_install_ft          "Советы по форуму"
_tr_add2 after_install_fttip       "Обратитесь к нам за помощью$_exclamation"


_tr_add2 general_info_text         "Найди себя в blackarch-lightweight"

_tr_add2 general_info_ws           "Сайт"

_tr_add2 general_info_wi           "Wiki"
_tr_add2 general_info_witip        "Опубликованные статьи"

_tr_add2 general_info_ne           "Новости"
_tr_add2 general_info_netip        "Новости и статьи"

_tr_add2 general_info_fo           "Форум"
_tr_add2 general_info_fotip        "Спрашивайте, комментируйте и общайтесь на нашем дружественном форуме$_exclamation"

_tr_add2 general_info_do           "Пожертвования"
_tr_add2 general_info_dotip        "Окажите помощь в развитии и поддержке blackarch-lightweight"

_tr_add2 general_info_ab           "О Welcome"
_tr_add2 general_info_abtip        "Информация о приложении Welcome"


_tr_add2 add_more_apps_text        "Установка популярных программ"

_tr_add2 add_more_apps_lotip       "Office tools (libreoffice-fresh)"

_tr_add2 add_more_apps_ch          "Chromium"
_tr_add2 add_more_apps_chtip       "Chromium Web Browser"

_tr_add2 add_more_apps_fw          "Firewall"
_tr_add2 add_more_apps_fwtip       "Gufw firewall"

_tr_add2 add_more_apps_bt          "Bluetooth (blueberry) для Xfce"
_tr_add2 add_more_apps_bt_bm       "Bluetooth (blueman) для Xfce"


###################### НОВЫЕ ВЕЩИ ПОСЛЕ ЭТОЙ ЛИНИИ ######################

_tr_add2 settings_dis_contents     "Для запуска $PRETTY_PROGNAME повторно, откройте терминал и выполните команду: $PROGNAME --enable"
_tr_add2 settings_dis_text         "Перезапуск $PRETTY_PROGNAME:"
_tr_add2 settings_dis_title        "Как возобновить $PRETTY_PROGNAME"
_tr_add2 settings_dis_butt         "Я помню"
_tr_add2 settings_dis_buttip       "Я обещаю"

_tr_add2 help_butt_title           "$PRETTY_PROGNAME Help"
_tr_add2 help_butt_text            "Информация о приложении $PRETTY_PROGNAME"

_tr_add2 dm_title                  "Выбор Display Manager"
_tr_add2 dm_col_name1              "Выбранный"
_tr_add2 dm_col_name2              "Название Display Manager"

_tr_add2 dm_reboot_required        "Для применения изменений необходима перезагрузка"
_tr_add2 dm_changed                "Изменить Display Manager на: "
_tr_add2 dm_failed                 "Ошибка при смене DM"
_tr_add2 dm_warning_title          "Внимание"

_tr_add2 install_installer         "Установщик"
_tr_add2 install_already           "Уже установлено"
_tr_add2 install_ing               "Установка"
_tr_add2 install_done              "Финиш"

_tr_add2 sysup_no                  "Обновлений нет"
_tr_add2 sysup_check               "Проверка обновлений программ..."

_tr_add2 issues_title              "Обнаружена ошибка пакета"
_tr_add2 issues_grub               "ВАЖНОЕ ЗАМЕЧАНИЕ: необходимо вручную воссоздать загрузочное меню"
_tr_add2 issues_run                "Выполнение команды:"
_tr_add2 issues_no                 "Системных ошибок не обнаружено"

_tr_add2 cal_noavail               "Не доступно: "			# программа установки
_tr_add2 cal_warn                  "Внимание"
_tr_add2 cal_info1                 "Это релиз по развитию сообщества.\n\n"                                   				# необходимые специальности!
_tr_add2 cal_info2                 "<b>Оффлайн</b> вариант предоставляет рабочий стол Xfce с темой blackarch-lightweight.\nПодключение к интернет не требуется.\n\n"
_tr_add2 cal_info3                 "<b>Онлайн</b> вариант позволяет выбрать DE с оформлением по умолчанию.\nТребуется подключение к интернет.\n\n"
_tr_add2 cal_info4                 "Внимание: Этот релиз находится в процессе разработки. Пожалуйста, сообщите нам в случае ошибки.\n"
_tr_add2 cal_choose                "Выбор способа установки"
_tr_add2 cal_method                "Способ"
_tr_add2 cal_nosupport             "$PROGNAME: не поддерживаемый режим: "
_tr_add2 cal_nofile                "$PROGNAME: требуемый файл отсутствует: "
_tr_add2 cal_istarted              "Начало установки"
_tr_add2 cal_istopped              "Завершение установки"

_tr_add2 tail_butt                 "Закрыть это окно"
_tr_add2 tail_buttip               "Закрыть только это окно"


_tr_add2 ins_text                  "Установка blackarch-lightweight на компьютер"
_tr_add2 ins_start                 "Запуск установки"
_tr_add2 ins_starttip              "Запуcк установки blackarch-lightweight вместе с отладочным терминалом"
_tr_add2 ins_up                    "Обновить Welcome $_exclamation"
_tr_add2 ins_uptip                 "Обновить Welcome и перезапустить его"
_tr_add2 ins_keys                  "Pacman - gpg keys"
_tr_add2 ins_keystip               "Обновить список ключей шифрования репозиториев"
_tr_add2 ins_pm                    "Управление разделами диска"
_tr_add2 ins_pmtip                 "Создание и управление разделами на вашем диске с помощью Gparted"
_tr_add2 ins_rel                   "Информация о релизе"
_tr_add2 ins_reltip                "Расширенная информация о последнем релизе"
_tr_add2 ins_tips                  "Полезные советы"
_tr_add2 ins_tipstip               "Полезная информация для помощи при установке"
_tr_add2 ins_trouble               "Устранение неполадок"
_tr_add2 ins_troubletip            "Рекомендации по восстановлению системы"

_tr_add2 after_install_us_from     "Обновление из"			# AUR или вышерасположенный
_tr_add2 after_install_us_el       "Требуется повышение привилегий."
_tr_add2 after_install_us_done     "обновление выполнено."
_tr_add2 after_install_us_fail     "ошибка обновления$_exclamation"
 
# 2020-May-14:

_tr_add2 nb_tab_UsefulTips     "Советы"
_tr_add2 useful_tips_text      "Полезные советы"

# 2020-May-16:

_tr_add2 butt_changelog        "Изменения в Welcome"
_tr_add2 butt_changelogtip     "История изменений Welcome"

_tr_add2 after_install_themevan      "Xfce оригинальная тема"
_tr_add2 after_install_themevantip   "Использовать тему Xfce"

_tr_add2 after_install_themedef     "Xfce тема в стиле blackarch-lightweight"
_tr_add2 after_install_themedeftip  "использовать стиль blackarch-lightweight в теме Xfce"

# 2020-Jun-28:
_tr_add2 after_install_pclean       "Настройка очистки пакетов"
_tr_add2 after_install_pcleantip    "Настройка очистки кэша пакетов Pacman"

# 2020-Jul-04:
_tr_add2 nb_tab_OwnCommands         "Пользовательские команды"
_tr_add2 nb_tab_owncmds_text        "Добавление пользовательских команд"

# 2020-Jul-08:
_tr_add2 nb_tab_owncmdstip          "Справка по добавлению пользовательских команд"

_tr_add2 add_more_apps_akm          "Выбор ядра Linux"
_tr_add2 add_more_apps_akmtip       "Установка простого менеджера ядер Linux"

# 2020-Jul-15:
_tr_add2 butt_owncmds_help        "Справка: пользовательские команды"

# 2020-Aug-05:
_tr_add2 butt_owncmds_dnd         "Создание пользовательских кнопок"
_tr_add2 butt_owncmds_dnd_help    "Отображение окна для создания новых кнопок"

# 2020-Sep-03:
_tr_add2 ins_reso                 "Разрешение дисплея"
_tr_add2 ins_resotip              "Изменить разрешение дисплея"

# 2020-Sep-08:
_tr_add2 add_more_apps_arch          "Просмотр всех Arch пакетов"
_tr_add2 add_more_apps_aur           "Просмотр всех AUR пакетов"
_tr_add2 add_more_apps_done1_text    "Рекомендуемые приложения уже установлены$_exclamation"
_tr_add2 add_more_apps_done2_text    "\n\nТакже можно просмотреть все пакеты Arch и AUR, и установить их используя терминал.\n"
_tr_add2 add_more_apps_done2_tip1    "Для установки, используйте 'pacman' или 'yay'"
_tr_add2 add_more_apps_done2_tip2    "Для установки, используйте 'yay'"

# 2020-Sep-11:
_tr_add2 after_install_ew2        "Выбор обоев"   # was: "blackarch-lightweight wallpaper (choose)"
_tr_add2 after_install_ewtip2     "Выбор обоев blackarch-lightweight"                          # was: "Choose from blackarch-lightweight default wallpapers"

# 2020-Sep-15:
#    IMPORTANT NOTE:
#       - line 71:  changed text of 'after_install_ew'
#       - line 72:  changed text of 'after_install_ewtip'
#       - line 249: changed text of 'after_install_ew2'
#       - line 250: changed text of 'after_install_ewtip2'
