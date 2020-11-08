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

# Chinese:

### First some useful definitions:

_tr_lang=zh            # required helper variable for _tr_add2

# Help with some special characters (HTML). Yad has problems without them:
_exclamation='！'   # '!'
_and='&#38;'        # '&'
_question='？'      # '?'


###################### Now the actual strings to be translated: ######################
# func   <placeholder>         "string"

_tr_add2 welcome_disabled      "$PRETTY_PROGNAME 应用程序已被禁用，请使用 --enable 开关来强制启动它。"

_tr_add2 butt_later            "再见"
_tr_add2 butt_latertip         "保持 $PRETTY_PROGNAME 启用"

_tr_add2 butt_noshow           "不再显示"
_tr_add2 butt_noshowtip        "禁用 $PRETTY_PROGNAME"

_tr_add2 butt_help             "帮助"


_tr_add2 nb_tab_INSTALL        "安装"
_tr_add2 nb_tab_GeneralInfo    "通用信息"
_tr_add2 nb_tab_AfterInstall   "安装后"
_tr_add2 nb_tab_AddMoreApps    "安装更多程序"


_tr_add2 after_install_text    "安装后任务"

_tr_add2 after_install_um      "更换镜像"
_tr_add2 after_install_umtip   "在系统更新前更新镜像列表"

_tr_add2 after_install_us      "更新系统"
_tr_add2 after_install_ustip   "更新系统软件"

_tr_add2 after_install_dsi     "检查系统问题"
_tr_add2 after_install_dsitip  "检查系统软件包或其他地方的潜在问题"

_tr_add2 after_install_etl     "更新到最新的 blackarch$_question"
_tr_add2 after_install_etltip  "显示如何操作以更新到最新的 blackarch"

_tr_add2 after_install_cdm     "更换显示管理器（DM）"
_tr_add2 after_install_cdmtip  "更换一个不同的显示管理器（Display Manager）"

_tr_add2 after_install_ew      "blackarch 壁纸"
_tr_add2 after_install_ewtip   "更换壁纸为 EOS 的默认壁纸"


_tr_add2 after_install_pm      "软件包管理"
_tr_add2 after_install_pmtip   "如何使用 pacman 管理软件包"

_tr_add2 after_install_ay      "AUR $_and yay$_exclamation"
_tr_add2 after_install_aytip   "Arch 用户仓库（Arch User Repository）和 yay 的相关信息"

_tr_add2 after_install_hn      "硬件与网络"
_tr_add2 after_install_hntip   "让你的硬件正常工作"

_tr_add2 after_install_bt      "蓝牙"
_tr_add2 after_install_bttip   "如何使用蓝牙"

_tr_add2 after_install_nv      "NVIDIA 用户$_exclamation"
_tr_add2 after_install_nvtip   "使用 NVIDIA 安装工具"

_tr_add2 after_install_ft      "论坛小贴士"
_tr_add2 after_install_fttip   "帮助我们来帮助你！"


_tr_add2 general_info_text     "在 blackarch 网站查看更多信息$_exclamation"

_tr_add2 general_info_ws       "网站"

_tr_add2 general_info_wi       "Wiki"
_tr_add2 general_info_witip    "精选文章"

_tr_add2 general_info_ne       "新闻"
_tr_add2 general_info_netip    "新闻和公告"

_tr_add2 general_info_fo       "论坛"
_tr_add2 general_info_fotip    "在我们友好的论坛里提问、评论和交流！"

_tr_add2 general_info_do       "捐款"
_tr_add2 general_info_dotip    "帮助 blackarch 持续运转"

_tr_add2 general_info_ab       "关于 $PRETTY_PROGNAME"
_tr_add2 general_info_abtip    "有关此应用程序的更多信息"


_tr_add2 add_more_apps_text    "安装推荐的应用"

_tr_add2 add_more_apps_lotip   "办公软件 (libreoffice-fresh)"

_tr_add2 add_more_apps_ch      "Chromium 浏览器"
_tr_add2 add_more_apps_chtip   "网页浏览器"

_tr_add2 add_more_apps_fw      "防火墙"
_tr_add2 add_more_apps_fwtip   "Gufw 防火墙"

_tr_add2 add_more_apps_bt      "Xfce 上的蓝牙支持 (blueberry)"
_tr_add2 add_more_apps_bt_bm   "Xfce 上的蓝牙支持 (blueman)"


####################### NEW STUFF AFTER THIS LINE:

_tr_add2 settings_dis_contents   "如需再次运行 $PRETTY_PROGNAME，请在终端中运行：$PROGNAME --enable"
_tr_add2 settings_dis_text       "重新启用 $PRETTY_PROGNAME："
_tr_add2 settings_dis_title      "如何重新启用 $PRETTY_PROGNAME"
_tr_add2 settings_dis_butt       "我会记住"
_tr_add2 settings_dis_buttip     "我保证"

_tr_add2 help_butt_title         "$PRETTY_PROGNAME 帮助"
_tr_add2 help_butt_text          "与 $PRETTY_PROGNAME 应用程序有关的更多信息"

_tr_add2 dm_title                "选择显示管理器（DM）"
_tr_add2 dm_col_name1            "已选择"
_tr_add2 dm_col_name2            "DM 名"

_tr_add2 dm_reboot_required      "改动需要重新启动以生效。"
_tr_add2 dm_changed              "DM 已更改为："
_tr_add2 dm_failed               "更改 DM 失败。"
_tr_add2 dm_warning_title        "警告"

_tr_add2 install_installer       "安装向导"
_tr_add2 install_already         "已安装"
_tr_add2 install_ing             "正在安装"
_tr_add2 install_done            "已完成。"

_tr_add2 sysup_no                "没有更新。"
_tr_add2 sysup_check             "正在检查软件更新……"

_tr_add2 issues_title            "发现了软件包问题"
_tr_add2 issues_grub             "重要：需要手动重建启动菜单"
_tr_add2 issues_run              "正在运行命令："
_tr_add2 issues_no               "未发现重要的系统问题。"

_tr_add2 cal_noavail            "不可用："        # installer program
_tr_add2 cal_warn               "警告"
_tr_add2 cal_info1              "这是一个社区开发版本。\n\n"                                   # specials needed!
_tr_add2 cal_info2              "<b>离线</b>模式为您提供预设为 blackarch 主题的 Xfce 桌面。\n不需要互联网连接。\n\n"
_tr_add2 cal_info3              "<b>在线</b>模式让您选择自己想要的桌面环境，并配置为默认主题。\n需要互联网连接。\n\n"
_tr_add2 cal_info4              "请注意：此版本仍然在开发中，请报告问题以帮助我们使它更稳定。\n"
_tr_add2 cal_choose             "选择安装方式"
_tr_add2 cal_method             "方式"
_tr_add2 cal_nosupport          "$PROGNAME：不支持的模式："
_tr_add2 cal_nofile             "$PROGNAME：需要的文件未找到："
_tr_add2 cal_istarted           "安装已开始"
_tr_add2 cal_istopped           "安装已完成"

_tr_add2 tail_butt              "关闭此窗口"
_tr_add2 tail_buttip            "仅关闭此窗口"


_tr_add2 ins_text              "安装 blackarch 到磁盘"
_tr_add2 ins_start             "启动安装向导"
_tr_add2 ins_starttip          "启动 blackarch 安装向导，并启动一个调试用的终端"
_tr_add2 ins_up                "更新此程序$_exclamation"
_tr_add2 ins_uptip             "更新此程序并重新启动"
_tr_add2 ins_keys              "初始化 pacman 密钥环"
_tr_add2 ins_keystip           "初始化 pacman 的可信密钥清单"
_tr_add2 ins_pm                "分区管理工具"
_tr_add2 ins_pmtip             "启动 Gparted 以检查和管理磁盘分区结构"
_tr_add2 ins_rel               "最新版本信息"
_tr_add2 ins_reltip            "与最新版本有关的更多信息"
_tr_add2 ins_tips              "安装提示"
_tr_add2 ins_tipstip           "安装提示"
_tr_add2 ins_trouble           "疑难解答"
_tr_add2 ins_troubletip        "系统故障排除"

_tr_add2 after_install_us_from    "更新系统："                            # AUR or upstream
_tr_add2 after_install_us_el      "需要授权"
_tr_add2 after_install_us_done    "更新完成。"
_tr_add2 after_install_us_fail    "更新失败！"

# 2020-May-14:

_tr_add2 nb_tab_UsefulTips     "小贴士"
_tr_add2 useful_tips_text      "有用的技巧"

# 2020-May-16:

_tr_add2 butt_changelog        "更新日志"
_tr_add2 butt_changelogtip     "显示 Welcome 程序的更新日志"

_tr_add2 after_install_themevan      "Xfce 原版主题"
_tr_add2 after_install_themevantip   "使用 Xfce 的原版主题"

_tr_add2 after_install_themedef     "Xfce blackarch 默认主题"
_tr_add2 after_install_themedeftip  "使用 Xfce 的 blackarch 默认主题"

# 2020-Jun-28:
_tr_add2 after_install_pclean       "软件包清理选项"
_tr_add2 after_install_pcleantip    "配置软件包缓存清理服务"

# 2020-Jul-04:
_tr_add2 nb_tab_OwnCommands         "自定义命令"                   # modified 2020-Jul-08
_tr_add2 nb_tab_owncmds_text        "自定义的命令"                 # modified 2020-Jul-08

# 2020-Jul-08:
_tr_add2 nb_tab_owncmdstip          "添加自定义命令的帮助信息"

_tr_add2 add_more_apps_akm          "内核管理器"
_tr_add2 add_more_apps_akmtip       "一个小巧的 Linux 内核管理工具和信息源"

# 2020-Jul-15:
_tr_add2 butt_owncmds_help        "新手教程：自定义命令"

# 2020-Aug-05:
_tr_add2 butt_owncmds_dnd         "自定义命令拖拽"
_tr_add2 butt_owncmds_dnd_help    "显示一个窗口以将项目拖拽为新命令"

# 2020-Sep-03:
_tr_add2 ins_reso                 "更改显示分辨率"
_tr_add2 ins_resotip              "立即更改显示分辨率"
