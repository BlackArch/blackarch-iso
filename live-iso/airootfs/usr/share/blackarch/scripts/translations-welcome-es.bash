# Traducciones para la aplicación Welcome
#
# Nota : variables (como $PRETTY_PROGNAME abajo) pueden utilizarse si ya están definidos, ya sea
# - en el Welcome aplicación
# - globalmente
#
#
# Cualquier cadena debe ser definida como :
#
#    _tr_add <language> <placeholder> "string"
#          or
#    _tr_add2 <placeholder> "string"
#
# donde
#
#    _tr_add         Es una función bash que añade una "cadena" a la base de datos de palabras.
#    _tr_add2        Igual que _tr_add pero define el idioma usando la variable _tr_lang (abajo).
#    <language>      Un acrónimo para el idioma, por ejemplo "en" para el inglés (¡comprueba las variable LANG !).
#    <placeholder>   Un nombre predefinido que identifica el lugar en la aplicación de bienvenida donde se utiliza esta cadena.
#    "string"        La cadena traducida para la aplicación Welcome.

# Español :

### Primero algunas definiciones útiles :

_tr_lang=es            # variable de ayuda requerida para _tr_add2

# Ayuda con algunos caracteres especiales (HTML). Yad tiene problemas sin ellos :
_exclamation='&#33;'   # '!'
_and='&#38;'           # '&'
_question='&#63;'      # '?'

_exclamation_down='&#161;'   # '¡'
_question_down='&#191;'      # '¿'


###################### Ahora las cadenas reales a ser traducidas ######################
# func   <placeholder>            "string"

_tr_add2 welcome_disabled         "$PRETTY_PROGNAME La aplicación está desactivada. Para iniciarla de todas formas, usa la opción --enable."

_tr_add2 butt_later               "Hasta pronto"
_tr_add2 butt_latertip            "Mantener $PRETTY_PROGNAME activado"

_tr_add2 butt_noshow              "No mostrar más"
_tr_add2 butt_noshowtip           "Desactivar $PRETTY_PROGNAME"

_tr_add2 butt_help                "Ayuda"


_tr_add2 nb_tab_INSTALL           "INSTALAR"
_tr_add2 nb_tab_GeneralInfo       "Información General"
_tr_add2 nb_tab_AfterInstall      "Después Instalación"
_tr_add2 nb_tab_AddMoreApps       "Añadir Aplicaciones"


_tr_add2 after_install_text       "Tareas después de la instalación"

_tr_add2 after_install_um         "Actualizar Servidores"
_tr_add2 after_install_umtip      "Actualizar la lista de servidores antes de la actualización del sistema"

_tr_add2 after_install_us         "Actualizar Sistema"
_tr_add2 after_install_ustip      "Actualizar el software del sistema"

_tr_add2 after_install_dsi        "Detectar bug Sistema"
_tr_add2 after_install_dsitip     "Detectar cualquier problema potencial en los paquetes del sistema o en otro lugar"

_tr_add2 after_install_etl        "${_question_down}blackarch más reciente$_question"
_tr_add2 after_install_etltip     "Mostrar qué hacer para que tu sistema llegue al último nivel de blackarch"

_tr_add2 after_install_cdm        "Cambiar Gestor Pantalla"
_tr_add2 after_install_cdmtip     "Usar un gestor de pantalla diferente"

_tr_add2 after_install_ew         "Fondo de pantalla barch"
_tr_add2 after_install_ewtip      "Cambiar el fondo de pantalla al que trae blackarch por defecto"


_tr_add2 after_install_pm         "Gestor Paquetes"
_tr_add2 after_install_pmtip      "Cómo manejar los paquetes con pacman"

_tr_add2 after_install_ay         "${_exclamation_down}AUR $_and yay$_exclamation"
_tr_add2 after_install_aytip      "Información de AUR y yay"

_tr_add2 after_install_hn         "Hardware y Red"
_tr_add2 after_install_hntip      "Ponga a funcionar su hardware"

_tr_add2 after_install_bt         "Bluetooth"
_tr_add2 after_install_bttip      "Consejo de bluetooth"

_tr_add2 after_install_nv         "${_exclamation_down}Usuarios NVIDIA$_exclamation"
_tr_add2 after_install_nvtip      "Utilice el instalador de NVIDIA"

_tr_add2 after_install_ft         "Consejos Foro"
_tr_add2 after_install_fttip      "${_exclamation_down}Ayúdanos a ayudarte$_exclamation"


_tr_add2 general_info_text        "${_exclamation_down}Encuentra tu camino en el sitio blackarch$_exclamation"

_tr_add2 general_info_ws          "Sitio web"

_tr_add2 general_info_wi          "Wiki"
_tr_add2 general_info_witip       "Artículos destacados"

_tr_add2 general_info_ne          "Noticias"
_tr_add2 general_info_netip       "Noticias y artículos"

_tr_add2 general_info_fo          "Foro"
_tr_add2 general_info_fotip       "${_exclamation_down}Pregunte, comente y charle en nuestro amigable foro$_exclamation"

_tr_add2 general_info_do          "Donar"
_tr_add2 general_info_dotip       "${_exclamation_down}Ayúdanos a mantener el blackarch funcionando"

_tr_add2 general_info_ab          "Acerca de $PRETTY_PROGNAME"
_tr_add2 general_info_abtip       "Más información sobre esta aplicación"


_tr_add2 add_more_apps_text       "Instalar aplicaciones populares"

_tr_add2 add_more_apps_lotip      "Herramientas ofimáticas (libreoffice-fresh)"

_tr_add2 add_more_apps_ch         "Chromium"
_tr_add2 add_more_apps_chtip      "Navegador Web"

_tr_add2 add_more_apps_fw         "Firewall"
_tr_add2 add_more_apps_fwtip      "Gufw firewall"

_tr_add2 add_more_apps_bt         "Bluetooth (blueberry) Xfce"
_tr_add2 add_more_apps_bt_bm      "Bluetooth (blueman) Xfce"


####################### COSAS NUEVAS DESPUÉS DE ESTA LÍNEA  ######################

_tr_add2 settings_dis_contents    "Para ejecutar $PRETTY_PROGNAME de nuevo, inicia una terminal y ejecuta : $PROGNAME --enable"
_tr_add2 settings_dis_text        "Reactivación $PRETTY_PROGNAME :"
_tr_add2 settings_dis_title       "Cómo volver a reactivar $PRETTY_PROGNAME"
_tr_add2 settings_dis_butt        "Lo recuerdo"
_tr_add2 settings_dis_buttip      "Lo prometo"

_tr_add2 help_butt_title          "$PRETTY_PROGNAME Ayuda"
_tr_add2 help_butt_text           "Más información sobre la aplicación $PRETTY_PROGNAME"

_tr_add2 dm_title                 "Seleccione el Gestor de pantalla"
_tr_add2 dm_col_name1             "Seleccionado"
_tr_add2 dm_col_name2             "Nombre del gestor de pantalla"

_tr_add2 dm_reboot_required       "Es necesario reiniciar para que los cambios surtan efecto."
_tr_add2 dm_changed               "Gestor de pantalla cambiado a : "
_tr_add2 dm_failed                "El cambio de gestor de pantalla falló."
_tr_add2 dm_warning_title         "Alerta"

_tr_add2 install_installer        "Instalador"
_tr_add2 install_already          "Ya instalado"
_tr_add2 install_ing              "Instalando"
_tr_add2 install_done             "Terminado."

_tr_add2 sysup_no                 "No hay actualizaciones."
_tr_add2 sysup_check              "Buscando actualizaciones de software..."

_tr_add2 issues_title             "Detección de errores en los paquetes"
_tr_add2 issues_grub              "IMPORTANTE : será necesario volver a crear el menú de arranque manualmente."
_tr_add2 issues_run               "Comandos de ejecución :"
_tr_add2 issues_no                "No se detectaron problemas importantes del sistema."

_tr_add2 cal_noavail              "No está disponible : "        # programa de instalación
_tr_add2 cal_warn                 "Alerta"
_tr_add2 cal_info1                "Este es un lanzamiento de desarrollo comunitario.\n\n"                                   # specials needed !
_tr_add2 cal_info2                "<b>Offline</b> Este método te da un escritorio Xfce con temas de blackarch.\nNo es necesario tener conexión a internet.\n\n"
_tr_add2 cal_info3                "<b>Online</b> Este método te permite elegir tu escritorio, con temas sin personalización.\nEs necesario tener conexión a internet.\n\n"
_tr_add2 cal_info4                "Por favor tenga en cuenta : Este lanzamiento es un trabajo en progreso, por favor ayúdenos a estabilizarlo reportando errores..\n"
_tr_add2 cal_choose               "Elija el método de instalación"
_tr_add2 cal_method               "Método"
_tr_add2 cal_nosupport            "$PROGNAME : modo no soportado : "
_tr_add2 cal_nofile               "$PROGNAME : el archivo requerido no existe : "
_tr_add2 cal_istarted             "La instalación comenzó"
_tr_add2 cal_istopped             "La instalación terminó"

_tr_add2 tail_butt                "Cerrar esta ventana"
_tr_add2 tail_buttip              "Cerrar sólo esta ventana"


_tr_add2 ins_text                 "Instalando blackarch en el disco"
_tr_add2 ins_start                "Inicie el instalador"
_tr_add2 ins_starttip             "Inicie el instalador del blackarch junto con una terminal de debug"
_tr_add2 ins_up                   "${_exclamation_down}Actualizar esta aplicación$_exclamation"
_tr_add2 ins_uptip                "Actualiza esta aplicación y reiniciarla"
_tr_add2 ins_keys                 "Iniciar las teclas del pacman"
_tr_add2 ins_keystip              "Iniciar las teclas del pacman"
_tr_add2 ins_pm                   "Gestor de particiones"
_tr_add2 ins_pmtip                "Gparted permite examinar y gestionar las particiones y la estructura del disco"
_tr_add2 ins_rel                  "Información sobre el último lanzamiento"
_tr_add2 ins_reltip               "Más información sobre el último lanzamiento"
_tr_add2 ins_tips                 "Consejos de instalación"
_tr_add2 ins_tipstip              "Consejos de instalación"
_tr_add2 ins_trouble              "Solución de problemas"
_tr_add2 ins_troubletip           "Recuperar el sistema"

_tr_add2 after_install_us_from    "Actualizar desde"                            # AUR o upstream
_tr_add2 after_install_us_el      "Se requieren privilegios elevados."
_tr_add2 after_install_us_done    "Actualización finalizada."
_tr_add2 after_install_us_fail    "${_exclamation_down}La actualización falló$_exclamation"

# 2020-May-14:

_tr_add2 nb_tab_UsefulTips     "Consejos"
_tr_add2 useful_tips_text      "Consejos útiles"

# 2020-May-16:

_tr_add2 butt_changelog        "Registro de cambios"
_tr_add2 butt_changelogtip     "Mostrar el registro de cambios de Welcome"

_tr_add2 after_install_themevan      "Tema sin personalización Xfce"
_tr_add2 after_install_themevantip   "Usar tema sin personalización Xfce"

_tr_add2 after_install_themedef     "Tema por defecto Xfce de blackarch"
_tr_add2 after_install_themedeftip  "Usar tema por defecto Xfce de blackarch"

# 2020-Jun-28:
_tr_add2 after_install_pclean       "Configuración de limpieza de los paquetes"
_tr_add2 after_install_pcleantip    "Configurar el servicio de limpieza de la caché de paquetes"

# 2020-Jul-04:
_tr_add2 nb_tab_OwnCommands         "Comandos personales"                   # modified 2020-Jul-08
_tr_add2 nb_tab_owncmds_text        "Comandos personalizados"               # modified 2020-Jul-08

# 2020-Jul-08:
_tr_add2 nb_tab_owncmdstip          "Ayuda para agregar comandos personales"

_tr_add2 add_more_apps_akm          "Gestor del kernel"
_tr_add2 add_more_apps_akmtip       "Un pequeño gestor del kernel de linux y una fuente de información"
