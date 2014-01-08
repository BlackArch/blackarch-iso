-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init("/usr/share/awesome/themes/blackarch/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "xterm"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9 }, s, layouts[1])
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
    { "manual", terminal .. " -e man awesome" },
    { "edit config", editor_cmd .. " " .. awesome.conffile },
    { "restart", awesome.restart },
    { "quit", awesome.quit }
}

xtermmenu = {
    { "xterm (red)", "xterm -bg black -fg red" },
    { "xterm (green)", "xterm -bg black -fg green" },
    { "xterm (yellow)", "xterm -bg black -fg yellow" },
    { "xterm (white)", "xterm -bg black -fg white" }
}

browsermenu = {
    { "firefox", "firefox" },
    { "opera", "opera" }
}

antiforensicmenu = {
    { "sdel", "xterm -bg black -fg red -e 'sdel -h ; bash'" },
    { "sfill", "xterm -bg black -fg red -e 'sfill -h ; bash'" },
    { "smem-secure-delete", "xterm -bg black -fg red -e 'smem-secure-delete -h ; bash'" },
    { "srm", "xterm -bg black -fg red -e 'srm -h ; bash'" },
    { "sswap", "xterm -bg black -fg red -e 'sswap -h ; bash'" },
    { "the_cleaner.sh", "xterm -bg black -fg red -e 'the_cleaner.sh -h ; bash'" },
}

automationmenu = {
    { "cewl", "xterm -bg black -fg red -e 'cewl -h ; bash'" },
    { "cewl-fab", "xterm -bg black -fg red -e 'cewl -h ; bash'" },
    { "checksec", "xterm -bg black -fg red -e 'checksec --help ; bash'" },
    { "crunch", "xterm -bg black -fg red -e 'crunch -h ; bash'" },
    { "gooscan", "xterm -bg black -fg red -e 'gooscan -h ; bash'" },
    { "hackersh", "xterm -bg black -fg red -e 'hackersh -h ; bash'" },
    { "mitmap", "xterm -bg black -fg red -e 'mitmap -h ; bash'" },
    { "nfspy", "xterm -bg black -fg red -e 'nfspy -h ; bash'" },
    { "nfspysh", "xterm -bg black -fg red -e 'nfspysh -h ; bash'" },
    { "nfsshell", "xterm -bg black -fg red -e 'nfsshell -h ; bash" },
    { "panoptic", "xterm -bg black -fg red -e 'panoptic -h ; bash" },
    { "rsmangler", "xterm -bg black -fg red -e 'rsmangler -h ; bash" },
    { "sakis3g", "sakis3g" },
    { "simple-ducky", "xterm -bg black -fg red -e 'sudo simple-ducky ; bash'" },
    { "svcrack", "xterm -bg black -fg red -e 'svcrack -h ; bash'" },
    { "svcrash", "xterm -bg black -fg red -e 'svcrash -h ; bash'" },
    { "svmap", "xterm -bg black -fg red -e 'svmap -h ; bash'" },
    { "svreport", "xterm -bg black -fg red -e 'svreport -h ; bash'" },
    { "svwar", "xterm -bg black -fg red -e 'svwar -h ; bash'" },
    { "sploitctl", "xterm -bg black -fg red -e 'sploitctl -H ; bash'" },
    { "tiger", "xterm -bg black -fg red -e 'tiger -h ; bash'" },
    { "tigercron", "xterm -bg black -fg red -e 'tigercron -h ; bash'" },
    { "tigexp", "xterm -bg black -fg red -e 'tigexp -h ; bash'" },
    { "tlssled", "xterm -bg black -fg red -e 'tlssled -h ; bash'" },
    { "unix-privesc-check", "xterm -bg black -fg red -e 'unix-privesc-check ; bash'" },
    { "username-anarchy", "xterm -bg black -fg red -e 'username-anarchy -h ; bash'" },
    { "voiphopper", "xterm -bg black -fg red -e 'voiphopper -h ; bash'" },
    { "wiffy", "xterm -bg black -fg red -e 'sudo wiffy ; bash'" },
    { "wnmap", "xterm -bg black -fg red -e 'wnmap -h ; bash'" },
}

backdoormenu = {
    { "backdoor-factory", "xterm -bg black -fg red -e 'backdoor-factory -h ; bash'" },
    { "bgrep", "xterm -bg black -fg red -e 'bgrep ; bash'" },
    { "cymothoa", "xterm -bg black -fg red -e 'cymothoa -h ; bash'" },
    { "udp_server", "xterm -bg black -fg red -e 'udp_server ; bash'" },
    { "enyelkm", "xterm -bg black -fg red -e 'enyelkm -h ; bash'" },
    { "hotpatcher", "xterm -bg black -fg red -e 'hotpatcher -h ; bash'" },
    { "jynx2", "xterm -bg black -fg red -e 'jynx2 -h ; bash'" },
    { "ms-sys", "xterm -bg black -fg red -e 'ms-sys -h ; bash'" },
    { "rrs", "xterm -bg black -fg red -e 'rrs -h ; bash'" },
    { "rubilyn", "xterm -bg black -fg red -e 'cd /usr/share/rubilyn ; ls ; bash'" },
    { "trixd00r", "xterm -bg black -fg red -e 'trixd00r -H ; bash'" },
    { "tsh", "xterm -bg black -fg red -e 'cd /usr/share/tsh ; ls ; bash'" },
    { "webacoo", "xterm -bg black -fg red -e 'webacoo -h ; bash'" },
    { "webshells", "xterm -bg black -fg red -e 'cd /usr/share/webshells ; ls ; bash'" },
    { "weevely", "xterm -bg black -fg red -e 'weevely -h ; bash'" },
}

binarymenu = {
    { "backdoor-factory", "xterm -bg black -fg red -e 'backdoor-factory -h ; bash'" },
    { "binwally", "xterm -bg black -fg red -e 'binwally -h ; bash'" },
    { "ms-sys", "xterm -bg black -fg red -e 'ms-sys -h ; bash'" },
    { "packerid", "xterm -bg black -fg red -e 'packerid -h ; bash'" },
}

bluetoothmenu = {
    { "bluebugger", "xterm -bg black -fg red -e 'bluebugger -h ; bash'" },
    { "bluelog", "xterm -bg black -fg red -e 'bluelog -h ; bash'" },
    { "bluepot", "bluepot" },
    { "blueprint", "xterm -bg black -fg red -e 'blueprint -h ; bash'" },
    { "bluesnarfer", "xterm -bg black -fg red -e 'bluesnarfer -h ; bash'" },
    { "braces", "xterm -bg black -fg red -e 'braces -h ; bash'" },
    { "bss", "xterm -bg black -fg red -e 'bss -h ; bash'" },
    { "psm_scan", "xterm -bg black -fg red -e 'psm_scan -h ; bash'" },
    { "rfcomm_scan", "xterm -bg black -fg red -e 'rfcomm_scan -h ; bash'" },
    { "btscanner", "xterm -bg black -fg red -e 'btscanner -h ; bash'" },
    { "carwhisperer", "xterm -bg black -fg red -e 'carwhisperer -h ; bash'" },
    { "ghettotooth", "xterm -bg black -fg red -e 'ghettotooth ; bash'" },
    { "hidattack", "xterm -bg black -fg red -e 'hidattack -h ; bash'" },
    { "obexstress", "xterm -bg black -fg red -e 'obexstress -h ; bash'" },
    { "redfang", "xterm -bg black -fg red -e 'redfang -h ; bash'" },
    { "spooftooph", "xterm -bg black -fg red -e 'spooftooph -h ; bash'" },
    { "tanya", "xterm -bg black -fg red -e 'tanya ; bash'" },
    { "tbear", "xterm -bg black -fg red -e 'tbear -h ; bash'" },
    { "tbsearch", "xterm -bg black -fg red -e 'tbsearch ; bash'" },
    { "ubertooth-btle", "xterm -bg black -fg red -e 'ubertooth-btle -h ; bash'" },
    { "ubertooth-dump", "xterm -bg black -fg red -e 'ubertooth-dump -h ; bash'" },
    { "ubertooth-follow", "xterm -bg black -fg red -e 'ubertooth-follow -h ; bash'" },
    { "ubertooth-hop", "xterm -bg black -fg red -e 'ubertooth-hop -h ; bash'" },
    { "ubertooth-lap", "xterm -bg black -fg red -e 'ubertooth-lap -h ; bash'" },
    { "ubertooth-specan", "xterm -bg black -fg red -e 'ubertooth-specan -h ; bash'" },
    { "ubertooth-uap", "xterm -bg black -fg red -e 'ubertooth-uap -h ; bash'" },
    { "ubertooth-util", "xterm -bg black -fg red -e 'ubertooth-util -h ; bash'" },
}

codeauditmenu = {
    { "flawfinder", "xterm -bg black -fg red -e 'flawfinder -h ; bash'" },
    { "pscan", "xterm -bg black -fg red -e 'pscan -h ; bash'" },
}

crackermenu = {
    { "acccheck", "xterm -bg black -fg red -e 'acccheck -h ; bash'" },
    { "aesfix", "xterm -bg black -fg red -e 'aesfix ; bash'" },
    { "aeskeyfind", "xterm -bg black -fg red -e 'aeskeyfind -h ; bash'" },
    { "against", "xterm -bg black -fg red -e 'against ; bash'" },
    { "asleap", "xterm -bg black -fg red -e 'asleap -h ; bash'" },
    { "genkeys", "xterm -bg black -fg red -e 'genkeys -h ; bash'" },
    { "beleth", "xterm -bg black -fg red -e 'beleth -h ; bash'" },
    { "pxedump", "xterm -bg black -fg red -e 'pxedump -h ; bash'" },
    { "usbdump", "xterm -bg black -fg red -e 'usbdump -h ; bash'" },
    { "blackhash", "xterm -bg black -fg red -e 'blackhash ; bash'" },
    { "bob_admin-sse2", "xterm -bg black -fg red -e 'bob_admin-sse2 -h ; bash'" },
    { "bob_client-sse2", "xterm -bg black -fg red -e 'bob_client-sse2 -h ; bash'" },
    { "bob_server-sse2", "xterm -bg black -fg red -e 'bob_server_sse2 -h ; bash'" },
    { "brutessh", "xterm -bg black -fg red -e 'sudo brutessh -h ; bash'" },
    { "bully", "xterm -bg black -fg red -e 'bully -h ; bash'" },
    { "cewl", "xterm -bg black -fg red -e 'cewl -h ; bash'" },
    { "cewl-fab", "xterm -bg black -fg red -e 'cewl -h ; bash'" },
    { "cisco-auditing-tool", "xterm -bg black -fg red -e 'cisco-auditing-tool ; bash'" },
    { "cisco-ocs", "xterm -bg black -fg red -e 'cisco-ocs ; bash'" },
    { "cmospwd", "xterm -bg black -fg red -e 'cmospwd -h ; bash'" },
    { "cowpatty", "xterm -bg black -fg red -e 'cowpatty -h ; bash'" },
    { "genpmk", "xterm -bg black -fg red -e 'genpmk -h ; bash'" },
    { "creddump", "xterm -bg black -fg red -e 'creddump" },
    { "crunch", "xterm -bg black -fg red -e 'crunch ; bash'" },
    { "cupp", "xterm -bg black -fg red -e 'cupp ; bash'" },
    { "dbpwaudit", "xterm -bg black -fg red -e 'dbpwaudit ; bash'" },
    { "dpeparser", "xterm -bg black -fg red -e 'dpeparser -h ; bash'" },
    { "eapmd5pass", "xterm -bg black -fg red -e 'eapmd5pass ; bash'" },
    { "enabler", "xterm -bg black -fg red -e 'enabler ; bash'" },
    { "evilmaid", "xterm -bg black -fg red -e 'evilmaid ; bash'" },
    { "fang", "xterm -bg black -fg red -e 'fang -h ; bash'" },
    { "fern", "xterm -bg black -fg red -e 'fern ; bash'" },
    { "findmyhash", "xterm -bg black -fg red -e 'findmyhash -h ; bash'" },
    { "hashcat", "xterm -bg black -fg red -e 'hashcat ; bash'" },
    { "hashcat-combinator", "xterm -bg black -fg red -e 'hashcat-combinator ; bash'" },
    { "hashcat-cutb", "xterm -bg black -fg red -e 'hashcat-cutb ; bash'" },
    { "hashcat-expander", "xterm -bg black -fg red -e 'hashcat-expander -h ; bash'" },
    { "hashcat-gate", "xterm -bg black -fg red -e 'hashcat-gate ; bash'" },
    { "hashcat-hcstatgen", "xterm -bg black -fg red -e 'hashcat-hcstatgen ; bash'" },
    { "hashcat-len", "xterm -bg black -fg red -e 'hashcat-len ; bash'" },
    { "hashcat-morph", "xterm -bg black -fg red -e 'hashcat-morph ; bash'" },
    { "hashcat-permute", "xterm -bg black -fg red -e 'hashcat-permute -h ; bash'" },
    { "hashcat-prepare", "xterm -bg black -fg red -e 'hashcat-prepare -h ; bash'" },
    { "hashcat-req", "xterm -bg black -fg red -e 'hashcat-req ; bash'" },
    { "hashcat-rli", "xterm -bg black -fg red -e 'hashcat-rli ; bash'" },
    { "hashcat-rli2", "xterm -bg black -fg red -e 'hashcat-rli2 ; bash'" },
    { "hashcat-splitlen", "xterm -bg black -fg red -e 'hashcat-splitlen ; bash'" },
    { "hashtag", "xterm -bg black -fg red -e 'hashtag -h ; bash'" },
    { "dpl4hydra", "xterm -bg black -fg red -e 'dpl4hydra.sh -h ; bash'" },
    { "hydra", "xterm -bg black -fg red -e 'hydra -h ; bash'" },
    { "pw-inspector", "xterm -bg black -fg red -e 'pw-inspector -h ; bash'" },
    { "xhydra", "xhydra" },
    { "iheartxor", "xterm -bg black -fg red -e 'iheartxor ; bash'" },
    { "ikecrack", "xterm -bg black -fg red -e 'ikecrack-snarf.pl'" },
    { "inguma", "xterm -bg black -fg red -e 'inguma ; bash'" },
    { "jbrute", "xterm -bg black -fg red -e 'jbrute --help ; bash'" },
    { "johnny", "johnny" },
    { "keimpx", "xterm -bg black -fg red -e 'keimpx -h ; bash'" },
    { "lodowep", "xterm -bg black -fg red -e 'lodowep -h ; bash'" },
    { "maskprocessor", "xterm -bg black -fg red -e 'maskprocessor -h ; bash'" },
    { "masscan", "xterm -bg black -fg red -e 'masscan --help ; bash'" },
    { "mdcrack", "xterm -bg black -fg red -e 'mdcrack ; bash'" },
    { "medusa", "xterm -bg black -fg red -e 'medusa -h ; bash'" },
    { "mfoc", "xterm -bg black -fg red -e 'mfoc -h ; bash'" },
    { "morxbrute", "xterm -bg black -fg red -e 'MorXBrute ; bash'" },
    { "onesixtyone", "xterm -bg black -fg red -e 'onesixtyone ; bash'" },
    { "owabf", "xterm -bg black -fg red -e 'owabf ; bash'" },
    { "maskgen", "xterm -bg black -fg red -e 'maskgen -h ; bash'" },
    { "policygen", "xterm -bg black -fg red -e 'policygen -h ; bash'" },
    { "rulegen", "xterm -bg black -fg red -e 'rulegen -h ; bash'" },
    { "statsgen", "xterm -bg black -fg red -e 'statsgen -h ; bash'" },
    { "passcracking", "xterm -bg black -fg red -e 'passcracking ; bash'" },
    { "patator", "xterm -bg black -fg red -e 'patator --help ; bash'" },
    { "pdfcrack", "xterm -bg black -fg red -e 'pdfcrack ; bash'" },
    { "pdgmail", "xterm -bg black -fg red -e 'pdgmail -h ; bash'" },
    { "phoss", "xterm -bg black -fg red -e 'PHoss -h ; bash'" },
    { "php-mt-seed", "xterm -bg black -fg red -e 'php_mt_seed ; bash'" },
    { "phrasendrescher", "xterm -bg black -fg red -e 'phrasendrescher -h ; bash'" },
}

cryptomenu = {
    { "bletchley-analyze", "xterm -bg black -fg red -e 'bletchley-analyze ; bash'" },
    { "bletchley-decode", "xterm -bg black -fg red -e 'bletchley-decode ; bash'" },
    { "bletchley-encode", "xterm -bg black -fg red -e 'bletchley-encode ; bash'" },
    { "bletchley-http2py", "xterm -bg black -fg red -e 'bletchley-http2py ; bash'" },
    { "bletchley-nextrand", "xterm -bg black -fg red -e 'bletchley-nextrand ; bash" },
    { "ciphertest", "xterm -bg black -fg red -e 'ciphertest ; bash'" },
    { "hash-identifier", "xterm -bg black -fg red -e 'hashid ; bash'" },
    { "nomorexor", "xterm -bg black -fg red -e 'nomorexor ; bash'" },
    { "sbd", "xterm -bg black -fg red -e 'sbd -h ; bash'" },
    { "xorbruteforcer", "xterm -bg black -fg red -e 'xorbruteforcer ; bash'" },
    { "xorsearch", "xterm -bg black -fg red -e 'xorsearch ; bash'" },
    { "xortool", "xterm -bg black -fg red -e 'xortool -h ; bash'" },
}

databasemenu = {
    { "sqlcheck", "xterm -bg black -fg red -e 'sqlcheck -h ; bash'" },
    { "sqldata", "xterm -bg black -fg red -e 'sqldata -h ; bash'" },
    { "getsids", "xterm -bg black -fg red -e 'getsids ; bash'" },
    { "metacoretex", "metacoretex" },
    { "minimysqlator", "minimysqlator" },
}

debuggermenu = {
    { "edb", "edb" },
    { "ollydbg", "ollydbg" },
    { "r2", "xterm -bg black -fg red -e 'r2 -h ; bash'" },
    { "r2agent", "xterm -bg black -fg red -e 'r2agent -h ; bash'" },
    { "rabin2", "xterm -bg black -fg red -e 'rabin2 -h ; bash'" },
    { "radare2", "xterm -bg black -fg red -e 'radare2 -h ; bash'" },
    { "radiff2", "xterm -bg black -fg red -e 'radiff2 -h ; bash'" },
    { "rafind2", "xterm -bg black -fg red -e 'rafind2 -h ; bash'" },
    { "ragg2", "xterm -bg black -fg red -e 'ragg2 -h ; bash'" },
    { "ragg2-cc", "xterm -bg black -fg red -e 'ragg2-cc -h ; bash'" },
    { "rahash2", "xterm -bg black -fg red -e 'rahash2 -h ; bash'" },
    { "rarun2", "xterm -bg black -fg red -e 'rarun2 -h ; bash'" },
    { "rasm2", "xterm -bg black -fg red -e 'rasm2 -h ; bash'" },
    { "rax2", "xterm -bg black -fg red -e 'rax2 ; bash'" },
    { "shellnoob", "xterm -bg black -fg red -e 'shellnoob ; bash'" },
    { "vdbbin", "xterm -bg black -fg red -e 'vdbbin -h ; bash'" },
    { "vivbin", "xterm -bg black -fg red -e 'vivbin -h ; bash'" },
}

decompilermenu = {
    { "flasm", "xterm -bg black -fg red -e 'flasm -h ; bash'" },
}

defensivemenu = {
    { "arpalert", "xterm -bg black -fg red -e 'arpalert -h ; bash'" },
    { "arpantispoofer", "xterm -bg black -fg red -e 'arpas -h ; bash'" },
    { "arpon", "xterm -bg black -fg red -e 'sudo arpon -h ; bash" },
    { "artillery", "xterm -bg black -fg red -e 'artillery ; bash'" },
    { "chkrootkit", "xterm -bg black -fg red -e 'chkrootkit -h ; bash'" },
    { "dbpwaudit", "xterm -bg black -fg red -e 'dbpwaudit ; bash'" },
    { "inetsim", "xterm -bg black -fg red -e 'inetsim --help ; bash'" },
    { "sniffjoke", "xterm -bg black -fg red -e 'sudo sniffjoke -h ; bash'" },
    { "sniffjokectl", "xterm -bg black -fg red -e 'sniffjokectl -h ; bash'" },
    { "tor-autocircuit", "xterm -bg black -fg red -e 'tor-autocircuit ; bash'" },
}

disassemblermenu = {
    { "inguma", "xterm -bg black -fg red -e 'inguma ; bash'" },
    { "r2", "xterm -bg black -fg red -e 'r2 -h ; bash'" },
    { "r2agent", "xterm -bg black -fg red -e 'r2agent -h ; bash'" },
    { "rabin2", "xterm -bg black -fg red -e 'rabin2 -h ; bash'" },
    { "radare2", "xterm -bg black -fg red -e 'radare2 -h ; bash'" },
    { "radiff2", "xterm -bg black -fg red -e 'radiff2 -h ; bash'" },
    { "rafind2", "xterm -bg black -fg red -e 'rafind2 -h ; bash'" },
    { "ragg2", "xterm -bg black -fg red -e 'ragg2 -h ; bash'" },
    { "ragg2-cc", "xterm -bg black -fg red -e 'ragg2-cc -h ; bash'" },
    { "rahash2", "xterm -bg black -fg red -e 'rahash2 -h ; bash'" },
    { "rarun2", "xterm -bg black -fg red -e 'rarun2 -h ; bash'" },
    { "rasm2", "xterm -bg black -fg red -e 'rasm2 -h ; bash'" },
    { "rax2", "xterm -bg black -fg red -e 'rax2 ; bash'" },
    { "vdbbin", "xterm -bg black -fg red -e 'vdbbin -h ; bash'" },
    { "vivbin", "xterm -bg black -fg red -e 'vivbin -h ; bash'" },
}

dosmenu = {
    { "dnsdrdos", "xterm -bg black -fg red -e 'dnsdrdos -H ; bash'" },
    { "hawk", "xterm -bg black -fg red -e 'hawk --help ; bash'" },
    { "hwk-eagle", "xterm -bg black -fg red -e 'hwk-eagle --help ; bash'" },
    { "iaxflood", "xterm -bg black -fg red -e 'iaxflood ; bash'" },
    { "mausezahn", "xterm -bg black -fg red -e 'sudo mz -h ; bash'" },
    { "nkiller2", "xterm -bg black -fg red -e 'nkiller2 -h ; bash'" },
    { "slowhttptest", "xterm -bg black -fg red -e 'slowhttptest -h ; bash'" },
    { "t50", "xterm -bg black -fg red -e 't50 --help ; bash'" },
    { "6to4test.sh", "xterm -bg black -fg red -e '6to4test.sh ; bash'" },
    { "address6", "xterm -bg black -fg red -e 'address6 ; bash'" },
    { "alive6", "xterm -bg black -fg red -e 'alive6 ; bash'" },
    { "applypatch-msg.sample", "xterm -bg black -fg red -e 'applypatch-msg.sample ; bash'" },
    { "commit-msg.sample", "xterm -bg black -fg red -e 'commit-msg.sample ; bash'" },
    { "covert_send6", "xterm -bg black -fg red -e 'covert_send6 ; bash'" },
}

dronemenu = {
    { "skyjack", "xterm -bg black -fg red -e 'skyjack --help ; bash'" },
}

exploitationmenu = {
    { "armitage", "armitage" },
    { "arpoison", "xterm -bg black -fg red -e 'arpoison -h ; bash'" },
    { "bbqsql", "xterm -bg black -fg red -e 'bbqsql -h ; bash'" },
    { "bed", "xterm -bg black -fg red -e 'bed -h ; bash'" },
    { "bfbtester", "xterm -bg black -fg red -e 'bfbtester -h ; bash'" },
    { "cisco-global-exploiter", "xterm -bg black -fg red -e 'cisco-global-exploiter -h ; bash'" },
    { "cisco-torch", "xterm -bg black -fg red -e 'cisco-torch -h ; bash'" },
    { "darkd0rk3r", "xterm -bg black -fg red -e 'darkd0rk3r ; rm -rf darkd0rk3r-*.txt ; bash'" },
    { "darkmysqli", "xterm -bg black -fg red -e 'darkmysqli -h ; bash'" },
    { "dotdotpwn", "xterm -bg black -fg red -e 'dotdotpwn -h ; bash'" },
    { "fimap", "xterm -bg black -fg red -e 'fimap -h ; bash'" },
    { "ferret", "xterm -bg black -fg red -e 'ferret ; bash'" },
    { "hamster-http", "xterm -bg black -fg red -e 'hamster-http -h ; bash'" },
    { "hcraft", "xterm -bg black -fg red -e 'hcraft ; bash'" },
    { "htexploit", "xterm -bg black -fg red -e 'htexploit -h ; bash'" },
    { "htshells", "xterm -bg black -fg red -e 'cd /usr/share/htshells ; ls ; bash'" },
    { "inguma", "xterm -bg black -fg red -e 'inguma ; bash'" },
    { "irpas-ass", "xterm -bg black -fg red -e 'irpas-ass ; bash'" },
    { "irpas-cdp", "xterm -bg black -fg red -e 'irpas-cdp ; bash'" },
    { "irpas-dfkaa", "xterm -bg black -fg red -e 'udo rpas-dfkaa ; bash'" },
    { "irpas-dhcpx", "xterm -bg black -fg red -e 'irpas-dhcpx ; bash'" },
    { "irpas-file2cable", "xterm -bg black -fg red -e 'irpas-file2cable ; bash'" },
    { "irpas-hsrp", "xterm -bg black -fg red -e 'irpas-hsrp ; bash'" },
    { "irpas-icmp_redirect", "xterm -bg black -fg red -e 'irpas-icmp_redirect ; bash'" },
    { "irpas-igrp", "xterm -bg black -fg red -e 'irpas-igrp ; bash'" },
    { "irpas-irdp", "xterm -bg black -fg red -e 'irpas-irdp ; bash'" },
    { "irpas-irdpresponder", "xterm -bg black -fg red -e 'irpas-irdpresponder ; bash'" },
    { "irpas-itrace", "xterm -bg black -fg red -e 'irpas-itrace ; bash'" },
    { "irpas-netenum", "xterm -bg black -fg red -e 'irpas-netenum ; bash'" },
    { "irpas-netmask", "xterm -bg black -fg red -e 'irpas-netmask ; bash'" },
    { "irpas-protos", "xterm -bg black -fg red -e 'irpas-protos ; bash'" },
    { "irpas-tctrace", "xterm -bg black -fg red -e 'irpas-tctrace ; bash'" },
    { "irpas-timestamp", "xterm -bg black -fg red -e 'irpas-timestamp ; bash'" },
    { "zbassocflood", "xterm -bg black -fg red -e 'zbassocflood ; bash'" },
    { "zbconvert", "xterm -bg black -fg red -e 'zbconvert ; bash'" },
    { "zbdsniff", "xterm -bg black -fg red -e 'zbdsniff ; bash'" },
    { "zbdump", "xterm -bg black -fg red -e 'zbdump ; bash'" },
    { "zbfind", "xterm -bg black -fg red -e 'zbfind ; bash'" },
    { "zbgoodfind", "xterm -bg black -fg red -e 'zbgoodfind ; bash'" },
    { "zbid", "xterm -bg black -fg red -e 'zbid ; bash'" },
    { "zbkey", "xterm -bg black -fg red -e 'zbkey ; bash'" },
    { "zbreplay", "xterm -bg black -fg red -e 'zbreplay ; bash'" },
    { "zbscapy", "xterm -bg black -fg red -e 'zbscapy ; bash'" },
    { "zbstumbler", "xterm -bg black -fg red -e 'zbstumbler ; bash'" },
    { "zbwireshark", "xterm -bg black -fg red -e 'zbwireshark ; bash'" },
    { "leroy-jenkins", "xterm -bg black -fg red -e 'leroy-jenkins ; bash'" },
    { "lfi-autopwn", "xterm -bg black -fg red -e 'lfi-autopwn ; bash'" },
    { "loki", "xterm -bg black -fg red -e 'sudo loki.py ; bash'" },
    { "mpls_tunnel", "xterm -bg black -fg red -e 'mpls_tunnel ; bash'" },
    { "msfbinscan", "xterm -bg black -fg red -e 'msfbinscan -h ; bash'" },
    { "msfcli", "xterm -bg black -fg red -e 'msfcli -h ; bash'" },
    { "msfconsole", "xterm -bg black -fg red -e 'msfconsole -h ; bash'" },
    { "msfd", "xterm -bg black -fg red -e 'msfd -h ; bash'" },
    { "msfelfscan", "xterm -bg black -fg red -e 'msfelfscan -h ; bash'" },
    { "msfencode", "xterm -bg black -fg red -e 'msfencode -h ; bash'" },
    { "msfmachscan", "xterm -bg black -fg red -e 'msfmachscan -h ; bash'" },
    { "msfpayload", "xterm -bg black -fg red -e 'msfpayload -h ; bash'" },
    { "msfpescan", "xterm -bg black -fg red -e 'msfpescan -h ; bash'" },
    { "msfrop", "xterm -bg black -fg red -e 'msfrop -h ; bash'" },
    { "msfrpc", "xterm -bg black -fg red -e 'msfrpc -h ; bash'" },
    { "msfrpcd", "xterm -bg black -fg red -e 'msfrpcd -h ; bash'" },
    { "msfupdate", "xterm -bg black -fg red -e 'msfupdate -h ; bash'" },
    { "msfvenom", "xterm -bg black -fg red -e 'msfvenom -h ; bash'" },
    { "msf_exec.py", "xterm -bg black -fg red -e 'msf_exec.py -h ; bash'" },
    { "miranda-upnp", "xterm -bg black -fg red -e 'miranda-upnp -h ; bash'" },
    { "miranda-upnp-portmapper", "xterm -bg black -fg red -e 'miranda-upnp-portmapper -h ; bash'" },
    { "mitmap", "xterm -bg black -fg red -e 'mitmap.sh -h ; bash'" },
    { "mitmdump", "xterm -bg black -fg red -e 'mitmdump -h ; bash'" },
    { "mitmproxy", "xterm -bg black -fg red -e 'mitmproxy -h ; bash'" },
    { "padbuster", "xterm -bg black -fg red -e 'padbuster -h ; bash'" },
    { "paxtest", "xterm -bg black -fg red -e 'paxtest -h ; bash'" },
    { "pblind", "xterm -bg black -fg red -e 'pblind ; bash'" },
    { "pentbox", "xterm -bg black -fg red -e 'pentbox ; bash'" },
    { "pirana", "xterm -bg black -fg red -e 'pirana -h ; bash'" },
    { "powersploit", "xterm -bg black -fg red -e 'cd /usr/share/windows/powersploit ; ls ; bash'" },
    { "rebind", "xterm -bg black -fg red -e 'rebind_dns -h ; bash'" },
    { "rfcat", "xterm -bg black -fg red -e 'rfcat -h ; bash'" },
    { "ropeme-exploit", "xterm -bg black -fg red -e 'ropeme-exploit ; bash'" },
    { "ropeme-readelf", "xterm -bg black -fg red -e 'ropeme-readelf ; bash'" },
    { "ropeme-search-gadgets", "xterm -bg black -fg red -e 'ropeme-search-gadgets ; bash'" },
    { "ropshell", "xterm -bg black -fg red -e 'ropshell ; bash'" },
    { "ropgadget", "xterm -bg black -fg red -e 'ropgadget ; bash'" },
    { "seautomate", "xterm -bg black -fg red -e 'seautomate ; bash'" },
    { "seproxy", "xterm -bg black -fg red -e 'seproxy ; bash'" },
    { "setoolkit", "xterm -bg black -fg red -e 'setoolkit ; bash'" },
    { "seupdate", "xterm -bg black -fg red -e 'seupdate ; bash'" },
    { "seweb", "xterm -bg black -fg red -e 'seweb ; bash'" },
    { "shellcodecs", "xterm -bg black -fg red -e 'shellcodecs ; ls ; bash'" },
    { "shellnoob", "xterm -bg black -fg red -e 'shellnoob -h ; bash'" },
    { "simple-ducky", "xterm -bg black -fg red -e 'sudo simple-ducky ; bash'" },
    { "svcrack", "xterm -bg black -fg red -e 'svcrack -h ; bash'" },
    { "svcrash", "xterm -bg black -fg red -e 'svcrash -h ; bash'" },
    { "svmap", "xterm -bg black -fg red -e 'svmap -h ; bash'" },
    { "svreport", "xterm -bg black -fg red -e 'svreport -h ; bash'" },
    { "svwar", "xterm -bg black -fg red -e 'svwar -h ; bash'" },
    { "sploitctl", "xterm -bg black -fg red -e 'sploitctl -H ; bash'" },
    { "sqlmap", "xterm -bg black -fg red -e 'sqlmap -hh ; bash'" },
    { "sqlninja", "xterm -bg black -fg red -e 'sqlninja -h ; bash'" },
    { "sqlsus", "xterm -bg black -fg red -e 'sqlsus -h ; bash'" },
    { "subterfuge", "xterm -bg black -fg red -e 'subterfuge ; bash'" },
    { "tcpjunk", "xterm -bg black -fg red -e 'tcpjunk -h ; bash'" },
    { "6to4test.sh", "xterm -bg black -fg red -e '6to4test.sh ; bash'" },
    { "address6", "xterm -bg black -fg red -e 'address6 ; bash'" },
    { "alive6", "xterm -bg black -fg red -e 'alive6 ; bash'" },
    { "applypatch-msg.sample", "xterm -bg black -fg red -e 'applypatch-msg.sample ; bash'" },
    { "commit-msg.sample", "xterm -bg black -fg red -e 'commit-msg.sample ; bash'" },
    { "covert_send6", "xterm -bg black -fg red -e 'covert_send6 ; bash'" },
}

fingerprintmenu = {
    { "asp-audit", "xterm -bg black -fg red -e 'asp-audit ; bash'" },
    { "blindelephant", "xterm -bg black -fg red -e 'blindelephant ; bash'" },
    { "cisco-torch", "xterm -bg black -fg red -e 'cisco-torch ; bash '" },
    { "cms-explorer", "xterm -bg black -fg red -e 'cms-explorer ; bash'" },
    { "httsquash", "xterm -bg black -fg red -e 'httsquash ; bash'" },
    { "letdown", "xterm -bg black -fg red -e 'letdown ; bash'" },
    { "reverseraider", "xterm -bg black -fg red -e 'reverseraider ; bash'" },
    { "dnsmap", "xterm -bg black -fg red -e 'dnsmap ; bash'" },
    { "dnsmap-bulk", "xterm -bg black -fg red -e 'dnsmap-bulk ; bash'" },
    { "ftpmap", "xterm -bg black -fg red -e 'ftpmap -h ; bash'" },
    { "httprint", "xterm -bg black -fg red -e 'httprint -h ; bash'" },
    { "kolkata", "xterm -bg black -fg red -e 'kolkata ; bash'" },
    { "p0f", "xterm -bg black -fg red -e 'p0f -h ; bash'" },
    { "p0f-client", "xterm -bg black -fg red -e 'p0f-client -h ; bash'" },
    { "p0f-sendsyn", "xterm -bg black -fg red -e 'p0f-sendsyn -h ; bash'" },
}

forensicmenu = {
    { "aesfix", "xterm -bg black -fg red -e 'aesfix ; bash'" },
    { "aeskeyfind", "xterm -bg black -fg red -e 'aeskeyfind ; bash'" },
    { "affcat", "xterm -bg black -fg red -e 'affcat ; bash'" },
    { "affcompare", "xterm -bg black -fg red -e 'affcompare ; bash'" },
    { "affconvert", "xterm -bg black -fg red -e 'affconvert ; bash'" },
    { "affcopy", "xterm -bg black -fg red -e 'affcopy ; bash'" },
    { "affcrypto", "xterm -bg black -fg red -e 'affcrypto ; bash'" },
    { "affdiskprint", "xterm -bg black -fg red -e 'affdiskprint ; bash'" },
    { "affinfo", "xterm -bg black -fg red -e 'affinfo ; bash'" },
    { "affix", "xterm -bg black -fg red -e 'affix ; bash'" },
    { "affrecover", "xterm -bg black -fg red -e 'affrecover ; bash'" },
    { "affsegment", "xterm -bg black -fg red -e 'affsegment ; bash'" },
    { "affsign", "xterm -bg black -fg red -e 'affsign ; bash'" },
    { "affstats", "xterm -bg black -fg red -e 'affstats ; bash'" },
    { "affuse", "xterm -bg black -fg red -e 'affuse ; bash'" },
    { "affverify", "xterm -bg black -fg red -e 'affverify ; bash'" },
    { "affxml", "xterm -bg black -fg red -e 'affxml ; bash'" },
    { "aimage", "xterm -bg black -fg red -e 'aimage -h ; bash'" },
    { "air", "xterm -bg black -fg red -e 'air ; bash'" },
    { "air-counter", "xterm -bg black -fg red -e 'air-counter ; bash'" },
    { "tailer", "xterm -bg black -fg red -e 'tailer --help ; bash'" },
    { "autopsy", "xterm -bg black -fg red -e 'autopsy -h ; bash'" },
    { "pxedump", "xterm -bg black -fg red -e 'pxedump ; bash'" },
    { "usbdump", "xterm -bg black -fg red -e 'usbdump ; bash'" },
    { "BEViewer", "xterm -bg black -fg red -e 'BEViewer -h ; bash'" },
    { "bulk-extractor", "xterm -bg black -fg red -e 'bulk-extractor ; bash'" },
    { "canari", "xterm -bg black -fg red -e 'canari ; bash'" },
    { "dispatcher", "xterm -bg black -fg red -e 'dispatcher -h ; bash'" },
    { "pysudo", "xterm -bg black -fg red -e 'pysudo -h ; bash'" },
    { "casefile", "xterm -bg black -fg red -e 'casefile -h ; bash'" },
    { "casefile", "xterm -bg black -fg red -e 'maltego -h ; bash'" },
    { "chkrootkit", "xterm -bg black -fg red -e 'chkrootkit -h ; bash'" },
    { "dc3dd", "xterm -bg black -fg red -e 'dc3dd --help ; bash'" },
    { "eindeutig", "xterm -bg black -fg red -e 'dbxparse -h ; bash'" },
    { "foremost", "xterm -bg black -fg red -e 'foremost -h ; bash'" },
    { "galleta", "xterm -bg black -fg red -e 'galleta ; bash'" },
    { "grokevt-addlog", "xterm -bg black -fg red -e 'grokevt-addlog ; bash'" },
    { "grokevt-builddb", "xterm -bg black -fg red -e 'grokevt-builddb ; bash'" },
    { "grokevt-dumpmsgs", "xterm -bg black -fg red -e 'grokevt-dumpmsgs ; bash'" },
    { "grokevt-findlogs", "xterm -bg black -fg red -e 'grokevt-findlogs ; bash'" },
    { "grokevt-parselog", "xterm -bg black -fg red -e 'grokevt-parselog ; bash'" },
    { "grokevt-ripdll", "xterm -bg black -fg red -e 'grokevt-ripdll ; bash'" },
    { "guymager", "xterm -bg black -fg red -e 'guymager ; bash'" },
    { "ewfacquire", "xterm -bg black -fg red -e 'ewfacquire ; bash'" },
    { "ewfacquirestream", "xterm -bg black -fg red -e 'ewfacquirestream ; bash'" },
    { "ewfdebug", "xterm -bg black -fg red -e 'ewfdebug ; bash'" },
    { "ewfexport", "xterm -bg black -fg red -e 'ewfexport ; bash'" },
    { "ewfinfo", "xterm -bg black -fg red -e 'ewfinfo ; bash'" },
    { "ewfmount", "xterm -bg black -fg red -e 'ewfmount ; bash'" },
    { "ewfrecover", "xterm -bg black -fg red -e 'ewfrecover ; bash'" },
    { "ewfverify", "xterm -bg black -fg red -e 'ewfverify ; bash'" },
    { "dupemap", "xterm -bg black -fg red -e 'dupemap ; bash'" },
    { "magicrescue", "xterm -bg black -fg red -e 'magicrescue ; bash'" },
    { "magicsort", "xterm -bg black -fg red -e 'magicsort ; bash'" },
    { "make-pdf", "xterm -bg black -fg red -e 'make-pdf-javascript ; bash'" },
    { "maltego", "xterm -bg black -fg red -e 'maltego -h ; bash'" },
    { "malwaredetect", "xterm -bg black -fg red -e 'malwaredetect ; bash'" },
    { "hashdeep", "xterm -bg black -fg red -e 'hashdeep -h ; bash'" },
    { "md5deep", "xterm -bg black -fg red -e 'md5deep -h ; bash'" },
    { "sha1deep", "xterm -bg black -fg red -e 'sha1deep -h ; bash'" },
    { "sha256deep", "xterm -bg black -fg red -e 'sha256deep -h ; bash'" },
    { "tigerdeep", "xterm -bg black -fg red -e 'tigerdeep -h ; bash'" },
    { "whirlpooldeep", "xterm -bg black -fg red -e 'whirlpooldeep -h ; bash'" },
    { "gmdb2", "xterm -bg black -fg red -e 'gmdb2 ; bash'" },
    { "mdb-array", "xterm -bg black -fg red -e 'mdb-array ; bash'" },
    { "mdb-export", "xterm -bg black -fg red -e 'mdb-export ; bash'" },
    { "mdb-header", "xterm -bg black -fg red -e 'mdb-header ; bash'" },
    { "mdb-hexdump", "xterm -bg black -fg red -e 'mdb-hexdump ; bash'" },
    { "mdb-parsecsv", "xterm -bg black -fg red -e 'mdb-parsecsv ; bash'" },
    { "mdb-prop", "xterm -bg black -fg red -e 'mdb-prop ; bash'" },
    { "mdb-schema", "xterm -bg black -fg red -e 'mdb-schema ; bash'" },
    { "mdb-sql", "xterm -bg black -fg red -e 'mdb-sql ; bash'" },
    { "mdb-tables", "xterm -bg black -fg red -e 'mdb-tables ; bash'" },
    { "mdb-ver", "xterm -bg black -fg red -e 'mdb-ver ; bash'" },
    { "memdump", "xterm -bg black -fg red -e 'memdump -h ; bash'" },
    { "memfetch", "xterm -bg black -fg red -e 'memfetch ; bash'" },
    { "nfex", "xterm -bg black -fg red -e 'nfex ; bash'" },
    { "origami", "xterm -bg black -fg red -e 'cd /usr/share/origami ; ls ; bash'" },
    { "pasco", "xterm -bg black -fg red -e 'pasco ; bash'" },
    { "pdf-parser", "xterm -bg black -fg red -e 'pdf-parser ; bash'" },
    { "pdfid", "xterm -bg black -fg red -e 'pdfid ; bash'" },
    { "peepdf", "xterm -bg black -fg red -e 'peepdf ; bash '" },
    { "ofs2rva", "xterm -bg black -fg red -e 'ofs2rva ; bash'" },
    { "pedis", "xterm -bg black -fg red -e 'pedis ; bash'" },
    { "pehash", "xterm -bg black -fg red -e 'pehash ; bash'" },
    { "pepack", "xterm -bg black -fg red -e 'pepack ; bash'" },
    { "pescan", "xterm -bg black -fg red -e 'pescan ; bash'" },
    { "pesec", "xterm -bg black -fg red -e 'pesec ; bash'" },
    { "pestr", "xterm -bg black -fg red -e 'pestr ; bash'" },
    { "readpe", "xterm -bg black -fg red -e 'readpe ; bash'" },
    { "rva2ofs", "xterm -bg black -fg red -e 'rva2ofs ; bash'" },
    { "recoverjpeg", "xterm -bg black -fg red -e 'recoverjpeg ; bash'" },
    { "recovermov", "xterm -bg black -fg red -e 'recovermov ; bash'" },
    { "remove-duplicates", "xterm -bg black -fg red -e 'remove-duplicates ; bash'" },
    { "sort-pictures", "xterm -bg black -fg red -e 'sort-pictures ; bash'" },
    { "reglookup", "xterm -bg black -fg red -e 'reglookup ; bash'" },
    { "reglookup-recover", "xterm -bg black -fg red -e 'reglookup-recover ; bash'" },
    { "reglookup-timeline", "xterm -bg black -fg red -e 'reglookup-timeline ; bash'" },
    { "rifiuti", "xterm -bg black -fg red -e 'rifiuti -h ; bash'" },
    { "rifiuti-vista", "xterm -bg black -fg red -e 'rifiuti-vista -h ; bash'" },
    { "rsakeyfind", "xterm -bg black -fg red -e 'rsakeyfind ; bash'" },
    { "safecopy", "xterm -bg black -fg red -e 'safecopy ; bash'" },
    { "scalpel", "xterm -bg black -fg red -e 'scalpel ; bash'" },
    { "scrounge-ntfs", "xterm -bg black -fg red -e 'scrounge-ntfs -h ; bash'" },
    { "vinetto", "xterm -bg black -fg red -e 'vinetto -h ; bash'" },
    { "volatility", "xterm -bg black -fg red -e 'volatility -h ; bash" },
    { "wyd", "xterm -bg black -fg red -e 'wyd ; bash'" },
}

fuzzermenu = {
    { "browser-fuzzer", "xterm -bg black -fg red -e 'bf3 ; bash'" },
    { "bss", "xterm -bg black -fg red -e 'sudo bss ; bash'" },
    { "psm_scan", "xterm -bg black -fg red -e 'psm_scan ; bash'" },
    { "rfcomm_scan", "xterm -bg black -fg red -e 'rfcomm_scan ; bash'" },
    { "bunny", "xterm -bg black -fg red -e 'cd /usr/share/bunny ; ls ; bash'" },
    { "burpsuite", "burpsuite" },
    { "cirt-fuzzer", "xterm -bg black -fg red -e 'cirt-fuzzer -help ; bash'" },
    { "cisco-auditing-tool", "xterm -bg black -fg red -e 'cisco-auditing-tool ; bash'" },
    { "conscan", "xterm -bg black -fg red -e 'conscan -h ; bash'" },
    { "cookie-cadger", "xterm -bg black -fg red -e 'cookie-cadger ; bash'" },
    { "dotdotpwn", "xterm -bg black -fg red -e 'dotdotpwn ; bash'" },
    { "easyfuzzer", "xterm -bg black -fg red -e 'easyfuzzer ; bash'" },
    { "easyfuzzer-proxy", "xterm -bg black -fg red -e 'easyfuzzer-proxy ; bash'" },
    { "easyfuzzer-proxy-misc", "xterm -bg black -fg red -e 'easyfuzzer-proxy-misc ; bash'" },
    { "mycrawler2", "xterm -bg black -fg red -e 'mycrawler2 ; bash'" },
    { "prepare4easyfuzzer", "xterm -bg black -fg red -e 'prepare4easyfuzzer ; bash'" },
    { "prepare4easyfuzzer-misc", "xterm -bg black -fg red -e 'prepare4easyfuzzer-misc ; bash'" },
    { "prepare4sqlfuzzer", "xterm -bg black -fg red -e 'prepare4sqlfuzzer ; bash'" },
    { "sqlfuzzer", "xterm -bg black -fg red -e 'sqlfuzzer ; bash'" },
    { "sqlfuzzer-proxy", "xterm -bg black -fg red -e 'sqlfuzzer-proxy ; bash'" },
    { "wbxml2request", "xterm -bg black -fg red -e 'wbxml2request ; bash'" },
    { "wsdl2request", "xterm -bg black -fg red -e 'wsdl2request ; bash'" },
    { "fimap", "xterm -bg black -fg red -e 'fimap -h ; bash'" },
    { "firewalk", "xterm -bg black -fg red -e 'firewalk ; bash'" },
    { "freport", "xterm -bg black -fg red -e 'freport ; bash'" },
    { "ftest", "xterm -bg black -fg red -e 'ftest ; bash'" },
    { "ftestd", "xterm -bg black -fg red -e 'ftestd ; bash'" },
    { "ftp-fuzz", "xterm -bg black -fg red -e 'ftp-fuzz -h ; bash'" },
    { "fusil-clamav", "xterm -bg black -fg red -e 'fusil-clamav ; bash'" },
    { "fusil-firefox", "xterm -bg black -fg red -e 'fusil-firefox ; bash'" },
    { "fusil-gettext", "xterm -bg black -fg red -e 'fusil-gettext ; bash'" },
    { "fusil-gimp", "xterm -bg black -fg red -e 'fusil-gimp ; bash'" },
    { "fusil-gstreamer", "xterm -bg black -fg red -e 'fusil-gstreamer ; bash'" },
    { "fusil-imagemagick", "xterm -bg black -fg red -e 'fusil-imagemagick ; bash'" },
    { "fusil-libc-printf", "xterm -bg black -fg red -e 'fusil-libc-printf ; bash'" },
    { "fusil-mplayer", "xterm -bg black -fg red -e 'fusil-mplayer ; bash'" },
    { "fusil-ogg123", "xterm -bg black -fg red -e 'fusil-ogg123 ; bash'" },
    { "fusil-php", "xterm -bg black -fg red -e 'fusil-php ; bash'" },
    { "fusil-poppler", "xterm -bg black -fg red -e 'fusil-poppler ; bash'" },
    { "fusil-python", "xterm -bg black -fg red -e 'fusil-python ; bash'" },
    { "fusil-vlc", "xterm -bg black -fg red -e 'fusil-vlc ; bash'" },
    { "fusil-wizzard", "xterm -bg black -fg red -e 'fusil-wizzard ; bash'" },
    { "fusil-zzuf", "xterm -bg black -fg red -e 'fusil-zzuf ; bash'" },
    { "fuzzball2", "xterm -bg black -fg red -e 'sudo fuzzball2 -h ; bash'" },
    { "fuzzdb", "xterm -bg black -fg red -e 'cd /usr/share/fuzzdb ; ls ; bash'" },
    { "fuzzdiff", "xterm -bg black -fg red -e 'fuzzdiff ; bash'" },
    { "hexorbase", "xterm -bg black -fg red -e 'hexorbase ; bash'" },
    { "http-fuzz", "xterm -bg black -fg red -e 'http-fuzz ; bash'" },
    { "hawk", "xterm -bg black -fg red -e 'hawk --help ; bash'" },
    { "hwk-eagle", "xterm -bg black -fg red -e 'hwk-eagle --help ; bash'" },
    { "ikeprober", "xterm -bg black -fg red -e 'ikeprober ; bash'" },
    { "inguma", "xterm -bg black -fg red -e 'inguma ; bash'" },
    { "jbrofuzz", "xterm -bg black -fg red -e 'jbrofuzz ; bash'" },
    { "lfi-autopwn", "xterm -bg black -fg red -e 'lfi-autopwn ; bash'" },
    { "mdk3", "xterm -bg black -fg red -e 'sudo mdk3 ; bash'" },
    { "msfbinscan", "xterm -bg black -fg red -e 'msfbinscan -h ; bash'" },
    { "msfcli", "xterm -bg black -fg red -e 'msfcli -h ; bash'" },
    { "msfconsole", "xterm -bg black -fg red -e 'msfconsole -h ; bash'" },
    { "msfd", "xterm -bg black -fg red -e 'msfd -h ; bash'" },
    { "msfelfscan", "xterm -bg black -fg red -e 'msfelfscan -h ; bash'" },
    { "msfencode", "xterm -bg black -fg red -e 'msfencode -h ; bash'" },
    { "msfmachscan", "xterm -bg black -fg red -e 'msfmachscan -h ; bash'" },
    { "msfpayload", "xterm -bg black -fg red -e 'msfpayload -h ; bash'" },
    { "msfpescan", "xterm -bg black -fg red -e 'msfpescan -h ; bash'" },
    { "msfrop", "xterm -bg black -fg red -e 'msfrop -h ; bash'" },
    { "msfrpc", "xterm -bg black -fg red -e 'msfrpc -h ; bash'" },
    { "msfrpcd", "xterm -bg black -fg red -e 'msfrpcd -h ; bash'" },
    { "msfupdate", "xterm -bg black -fg red -e 'msfupdate -h ; bash'" },
    { "msfvenom", "xterm -bg black -fg red -e 'msfvenom -h ; bash'" },
    { "msf_exec.py", "xterm -bg black -fg red -e 'msf_exec.py -h ; bash'" },
    { "nikto", "xterm -bg black -fg red -e 'nikto -H ; bash'" },
    { "notspikefile", "xterm -bg black -fg red -e 'notspikefile ; bash'" },
    { "oat", "xterm -bg black -fg red -e 'oat ; bash'" },
    { "ohrwurm", "xterm -bg black -fg red -e 'sudo ohrwurm -h ; bash'" },
    { "oscanner", "xterm -bg black -fg red -e 'oscanner -h ; bash'" },
    { "reportviewer", "xterm -bg black -fg red -e 'reportviewer -h ; bash'" },
    { "peach", "xterm -bg black -fg red -e 'peach ; bash'" },
    { "powerfuzzer", "powerfuzzer" },
    { "radamsa", "xterm -bg black -fg red -e 'radamsa -h ; bash'" },
    { "ratproxy", "xterm -bg black -fg red -e 'ratproxy -h ; bash'" },
    { "sfo", "xterm -bg black -fg red -e 'sfo ; bash'" },
    { "sfuzz", "xterm -bg black -fg red -e 'sfuzz -h ; bash'" },
    { "sfscandiff", "xterm -bg black -fg red -e 'sfscandiff -h ; bash'" },
    { "skipfish", "xterm -bg black -fg red -e 'skipfish -h ; bash'" },
    { "smtp-fuzz", "xterm -bg black -fg red -e 'smtp-fuzz ; bash'" },
    { "spiderpig-pdffuzzer", "xterm -bg black -fg red -e 'spiderpig-pdffuzzer ; bash" },
    { "spike-citrix", "xterm -bg black -fg red -e 'spike-citrix ; bash'" },
    { "spike-closed-source_web_server_fuzz", "xterm -bg black -fg red -e 'spike-closed-source_web_server_fuzz ; bash'" },
    { "spike-dceoversmb", "xterm -bg black -fg red -e 'spike-dceoversmb ; bash'" },
    { "spike-dltest", "xterm -bg black -fg red -e 'spike-dltest ; bash'" },
    { "spike-do-post", "xterm -bg black -fg red -e 'spike-do-post ; bash'" },
    { "spike-generic-chunked", "xterm -bg black -fg red -e 'spike-generic-chunked ; bash'" },
    { "spike-generic-listen_tcp", "xterm -bg black -fg red -e 'spike-generic-listen_tcp ; bash'" },
    { "spike-generic-send_tcp", "xterm -bg black -fg red -e 'spike-generic-send_tcp ; bash'" },
}

hardwaremenu = {
    { "arduino", "arduino" },
    { "d2j-apk-sign", "xterm -bg black -fg red -e 'd2j-apk-sign ; bash'" },
    { "d2j-asm-verify", "xterm -bg black -fg red -e 'd2j-asm-verify ; bash'" },
    { "d2j-decrpyt-string", "xterm -bg black -fg red -e 'd2j-decrpyt-string ; bash'" },
    { "d2j-dex-asmifier", "xterm -bg black -fg red -e 'd2j-dex-asmifier ; bash'" },
    { "d2j-dex-dump", "xterm -bg black -fg red -e 'd2j-dex-dump ; bash'" },
    { "d2j-dex2jar", "xterm -bg black -fg red -e 'd2j-dex2jar ; bash'" },
    { "d2j-init-deobf", "xterm -bg black -fg red -e 'd2j-init-deobf ; bash'" },
    { "d2j-jar-access", "xterm -bg black -fg red -e 'd2j-jar-access ; bash'" },
    { "d2j-jar-remap", "xterm -bg black -fg red -e 'd2j-jar-remap ; bash'" },
    { "d2j-jar2dex", "xterm -bg black -fg red -e 'd2j-jar2dex ; bash'" },
    { "d2j-jar2jasmin", "xterm -bg black -fg red -e 'd2j-jar2jasmin ; bash'" },
    { "d2j-jasmin2jar", "xterm -bg black -fg red -e 'd2j-jasmin2jar ; bash'" },
    { "kautilya", "xterm -bg black -fg red -e 'kautilya ; bash'" },
    { "baksmali", "xterm -bg black -fg red -e 'baksmali -h ; bash'" },
    { "smali", "xterm -bg black -fg red -e 'smali -h ; bash'" },
}

honeypotmenu = {
    { "artillery", "xterm -bg black -fg red -e 'sudo artillery ; bash" },
    { "bluepot", "bluepot" },
    { "fakeap", "xterm -bg black -fg red -e 'fakeap ; bash'" },
    { "fiked", "xterm -bg black -fg red -e 'fiked ; bash'" },
    { "honeyd", "xterm -bg black -fg red -e 'honeyd -h ; bash'" },
    { "honeydctl", "xterm -bg black -fg red -e 'honeydctl -h ; bash'" },
    { "honeydstats", "xterm -bg black -fg red -e 'honeydstats -h ; bash'" },
    { "hsniff", "xterm -bg black -fg red -e 'hsniff -h ; bash'" },
    { "inetsim", "xterm -bg black -fg red -e 'inetsim --help ; bash'" },
    { "kippo", "xterm -bg black -fg red -e 'cd /usr/share/kippo ; ls ; bash'" },
    { "wifi-honey", "xterm -bg black -fg red -e 'wifi-honey -h ; bash'" },
}

malwaremenu = {
    { "malwaredetect", "xterm -bg black -fg red -e 'malwaredetect ; bash'" },
    { "peepdf", "xterm -bg black -fg red -e 'peepdf -h ; bash'" },
    { "yara", "xterm -bg black -fg red -e 'yara ; bash'" },
    { "zerowine", "xterm -bg black -fg red -e 'cd /usr/share/zerowine ; ls ; bash'" },
}

miscmenu = {
    { "3proxy", "xterm -bg black -fg red -e '3proxy --help ; bash'" },
    { "countersutil", "xterm -bg black -fg red -e 'countersutil ; bash'" },
    { "dighosts", "xterm -bg black -fg red -e 'dighosts ; bash'" },
    { "ftppr", "xterm -bg black -fg red -e 'ftppr --help ; bash'" },
    { "mycrypt", "xterm -bg black -fg red -e 'mycrypt ; bash'" },
    { "pop3p", "xterm -bg black -fg red -e 'pop3p --help ; bash'" },
    { "socks", "xterm -bg black -fg red -e 'socks --help ; bash'" },
    { "tcppm", "xterm -bg black -fg red -e 'tcppm --help ; bash'" },
    { "udppm", "xterm -bg black -fg red -e 'udppm --help ; bash'" },
    { "airgraph-ng", "airgraph-ng" },
    { "binwalk", "xterm -bg black -fg red -e 'binwalk ; bash'" },
    { "BEViewer", "xterm -bg black -fg red -e 'BEViewer ; bash'" },
    { "bulk-extractor", "xterm -bg black -fg red -e 'bulk-extractor ; bash'" },
    { "copy-router-config.pl", "xterm -bg black -fg red -e 'copy-router-config.pl ; bash'" },
    { "merge-router-config.pl", "xterm -bg black -fg red -e 'merge-router-config.pl ; bash'" },
    { "cryptcat", "xterm -bg black -fg red -e 'cryptcat -h ; bash'" },
    { "dbd", "xterm -bg black -fg red -e 'dbd -h ; bash'" },
    { "dhcdrop", "xterm -bg black -fg red -e 'dhcdrop -h ; bash'" },
    { "elettra", "xterm -bg black -fg red -e 'elettra ; bash'" },
    { "elettra-gui", "elettra-gui" },
    { "ent", "xterm -bg black -fg red -e 'ent ; bash'" },
    { "evilgrade", "xterm -bg black -fg red -e 'evilgrade ; bash'" },
    { "fakemail", "xterm -bg black -fg red -e 'fakemail -h ; bash'" },
    { "firmware-mod-kit", "xterm -bg black -fg red -e 'firmware-mod-kit ; bash'" },
    { "flare", "xterm -bg black -fg red -e 'flare -h ; bash'" },
    { "genlist", "xterm -bg black -fg red -e 'genlist ; bash'" },
    { "geoedge", "xterm -bg black -fg red -e 'geoedge ; bash'" },
    { "geoipgen", "xterm -bg black -fg red -e 'geoipgen -h ; bash'" },
    { "hackersh", "xterm -bg black -fg red -e 'hackersh -h ; bash'" },
    { "http-put", "xterm -bg black -fg red -e 'http-put -h ; bash'" },
    { "inundator", "xterm -bg black -fg red -e 'inundator ; bash'" },
    { "laudanum", "xterm -bg black -fg red -e 'cd /usr/share/laudanum ; ls ; bash'" },
    { "leo", "xterm -bg black -fg red -e 'leo -h ; bash'" },
    { "leo-install.py", "xterm -bg black -fg red -e 'leo-install.py ; bash'" },
    { "leoc", "xterm -bg black -fg red -e 'leoc -h ; bash'" },
    { "list-urls", "xterm -bg black -fg red -e 'list-urls ; bash'" },
    { "MibbleBrowser", "xterm -bg black -fg red -e 'MibbleBrowser ; bash'" },
    { "MibblePrinter", "xterm -bg black -fg red -e 'MibblePrinter ; bash'" },
    { "MibbleValidator", "xterm -bg black -fg red -e 'MibbleValidator ; bash'" },
    { "netactview", "netactview" },
    { "oh-my-zsh-git", "xterm -bg black -fg red -e 'cd /usr/share/oh-my-zsh ; ls ; bash'" },
    { "pyinstaller", "xterm -bg black -fg red -e 'pyinstaller ; bash'" },
    { "sakis3g", "xterm -bg black -fg red -e 'sakis3g --help ; bash'" },
    { "schnappi-dhcp", "xterm -bg black -fg red -e 'schnappi-dhcp --help ; bash'" },
    { "sslcat", "xterm -bg black -fg red -e 'sslcat ; bash'" },
    { "sslyze", "xterm -bg black -fg red -e 'sslyze -h ; bash'" },
    { "stompy", "xterm -bg black -fg red -e 'stompy ; bash'" },
    { "tcpxtract", "xterm -bg black -fg red -e 'tcpxtract -h ; bash'" },
    { "tnscmd", "xterm -bg black -fg red -e 'tnscmd ; bash'" },
    { "tpcat", "xterm -bg black -fg red -e 'tpcat ; bash'" },
    { "uatester", "xterm -bg black -fg red -e 'uatester ; bash'" },
    { "vfeed", "xterm -bg black -fg red -e 'vfeed ; bash'" },
    { "wol-e", "xterm -bg black -fg red -e 'wol-e -h ; bash'" },
}

mobilemenu = {
    { "android-udev-rules", "android-udev-rules" },
}

networkingmenu = {
    { "httping", "xterm -bg black -fg red -e 'httping --help ; bash'" },
    { "hyenae", "xterm -bg black -fg red -e 'sudo hyenae --help ; bash'" },
    { "hyenaed", "xterm -bg black -fg red -e 'sudo hyenaed --help ; bash'" },
    { "total", "xterm -bg black -fg red -e 'total ; bash'" },
    { "ipaudit", "xterm -bg black -fg red -e 'ipaudit ; bash'" },
    { "ipstrings", "xterm -bg black -fg red -e 'ipstrings ; bash'" },
    { "jnetmap", "jnetmap" },
    { "mausezahn", "xterm -bg black -fg red -e 'sudo mz ; bash" },
    { "middler", "xterm -bg black -fg red -e 'middler -h ; bash'" },
    { "dnscat", "xterm -bg black -fg red -e 'dnscat ; bash'" },
    { "dnslogger", "xterm -bg black -fg red -e 'sudo dnslogger -h ; bash'" },
    { "dnstest", "xterm -bg black -fg red -e 'dnstest -h ; bash'" },
    { "dnsxss", "xterm -bg black -fg red -e 'sudo dnsxss -h ; bash'" },
    { "nbquery", "xterm -bg black -fg red -e 'nbquery -h ; bash'" },
    { "nbsniff", "xterm -bg black -fg red -e 'sudo nbsniff -h ; bash'" },
    { "makelist", "xterm -bg black -fg red -e 'makelist -h ; bash'" },
    { "netmap", "xterm -bg black -fg red -e 'netmap -h ; bash'" },
    { "netsed", "xterm -bg black -fg red -e 'netsed -h ; bash'" },
    { "nfex", "xterm -bg black -fg red -e 'nfex -h ; bash'" },
    { "nfsshell", "xterm -bg black -fg red -e 'nfsshell -h ; bash'" },
    { "nipper", "xterm -bg black -fg red -e 'nipper --help ; bash'" },
    { "nkiller2", "xterm -bg black -fg red -e 'nkiller2 -h ; bash'" },
    { "packit", "xterm -bg black -fg red -e 'packit ; bash'" },
    { "ptunnel", "xterm -bg black -fg red -e 'ptunnel -h ; bash'" },
    { "pwnat", "xterm -bg black -fg red -e 'pwnat -h ; bash'" },
    { "pyminifakedns", "xterm -bg black -fg red -e 'pyminifakedns ; bash'" },
    { "responder", "xterm -bg black -fg red -e 'responder -h ; bash'" },
    { "rtpbreak", "xterm -bg black -fg red -e 'rtpbreak -h ; bash'" },
    { "sbd", "xterm -bg black -fg red -e 'sbd -h ; bash'" },
    { "scapy", "xterm -bg black -fg red -e 'scapy -h ; bash'" },
    { "snmpcheck", "xterm -bg black -fg red -e 'snmpcheck-nothink ; bash'" },
    { "sslstrip", "xterm -bg black -fg red -e 'sslstrip -h ; bash'" },
    { "t50", "xterm -bg black -fg red -e 't50 --help ; bash'" },
    { "tcptraceroute", "xterm -bg black -fg red -e 'tcptraceroute ; bash'" },
    { "thc-ipv6", "xterm -bg black -fg red -e 'thc-ipv6 ; bash'" },
    { "udptunnel", "xterm -bg black -fg red -e 'udptunnel ; bash'" },
    { "wol-e", "xterm -bg black -fg red -e 'wol-e -h ; bash'" },
    { "yersinia", "xterm -bg black -fg red -e 'sudo yersinia --help ; bash'" },
    { "zarp", "xterm -bg black -fg red -e 'sudo zarp -h ; bash'" },
}

nfcmenu = {
    { "nfcutils", "xterm -bg black -fg red -e 'lsnfc ; bash'" },
}

packermenu = {
    { "packerid", "xterm -bg black -fg red -e 'packerid ; bash'" },
}

proxymenu = {
    { "burpsuite", "burpsuite" },
    { "dnschef", "xterm -bg black -fg red -e 'dnschef -h ; bash'" },
    { "fakedns", "xterm -bg black -fg red -e 'sudo fakedns ; bash'" },
    { "mitmdump", "xterm -bg black -fg red -e 'mitmdump -h ; bash'" },
    { "mitmproxy", "xterm -bg black -fg red -e 'mitmproxy -h ; bash'" },
    { "pathoc", "xterm -bg black -fg red -e 'pathoc -h ; bash'" },
    { "pathod", "xterm -bg black -fg red -e 'pathod -h ; bash'" },
    { "ratproxy", "xterm -bg black -fg red -e 'ratproxy -h ; bash'" },
    { "sergio-proxy", "xterm -bg black -fg red -e 'sergio-proxy -h ; bash'" },
    { "sslnuke", "xterm -bg black -fg red -e 'sslnuke ; bash'" },
    { "webscarab", "webscarab" },
}

reconmenu = {
    { "canari", "xterm -bg black -fg red -e 'canari -h ; bash'" },
    { "dispatcher", "xterm -bg black -fg red -e 'dispatcher -h ; bash'" },
    { "pysudo", "xterm -bg black -fg red -e 'pysudo -h ; bash'" },
    { "casefile", "xterm -bg black -fg red -e 'casefile --help ; bash'" },
    { "cutycapt", "CutyCapt" },
    { "dnsenum", "xterm -bg black -fg red -e 'dnsenum.pl -h ; bash'" },
    { "dnsrecon", "xterm -bg black -fg red -e 'dnsrecon -h ; bash'" },
    { "dnsspider", "xterm -bg black -fg red -e 'dnsspider -h ; bash'" },
    { "dnswalk", "xterm -bg black -fg red -e 'dnswalk --help ; bash" },
    { "enum4linux", "xterm -bg black -fg red -e 'enum4linux ; bash'" },
    { "goodork", "xterm -bg black -fg red -e 'goodork ; bash'" },
    { "goofile", "xterm -bg black -fg red -e 'goofile ; bash'" },
    { "goog-mail", "xterm -bg black -fg red -e 'goog-mail ; bash'" },
    { "gwtenum", "xterm -bg black -fg red -e 'gwtenum -h ; bash'" },
    { "gwtfuzzer", "xterm -bg black -fg red -e 'gwtfuzzer -h ; bash'" },
    { "gwtparse", "xterm -bg black -fg red -e 'gwtparse -h ; bash'" },
    { "halcyon", "xterm -bg black -fg red -e 'halcyon -h ; bash'" },
    { "httping", "xterm -bg black -fg red -e 'httping --help ; bash'" },
    { "intrace", "xterm -bg black -fg red -e 'intrace ; bash'" },
    { "isr-form", "xterm -bg black -fg red -e 'isr-form -h ; bash'" },
    { "lbd", "xterm -bg black -fg red -e 'lbd ; bash'" },
    { "ldapenum", "xterm -bg black -fg red -e 'ldapenum.pl ; bash'" },
    { "lft", "xterm -bg black -fg red -e 'lft ; bash'" },
    { "whob", "xterm -bg black -fg red -e 'whob ; bash'" },
    { "linux-exploit-suggester", "xterm -bg black -fg red -e 'linux-exploit-suggester -h ; bash'" },
    { "maltego", "maltego" },
    { "metagoofil", "xterm -bg black -fg red -e 'python2 /usr/bin/metagoofil ; bash'" },
    { "missidentify", "xterm -bg black -fg red -e 'missidentify -h ; bash'" },
    { "dnscat", "xterm -bg black -fg red -e 'dnscat -h ; bash'" },
    { "dnslogger", "xterm -bg black -fg red -e 'dnslogger -h ; bash'" },
    { "dnstest", "xterm -bg black -fg red -e 'dnstest -h ; bash'" },
    { "dnsxss", "xterm -bg black -fg red -e 'dnsxss -h ; bash'" },
    { "nbquery", "xterm -bg black -fg red -e 'nbquery -h ; bash'" },
    { "nbsniff", "xterm -bg black -fg red -e 'nbsniff -h ; bash'" },
    { "netdiscover", "xterm -bg black -fg red -e 'netdiscover -h ; bash'" },
    { "netmask", "xterm -bg black -fg red -e 'netmask --help ; bash'" },
    { "nipper", "xterm -bg black -fg red -e 'nipper --help ; bash'" },
    { "nsec3walker-collect", "xterm -bg black -fg red -e 'nsec3walker-collect ; bash'" },
    { "nsec3walker-dicthashes", "xterm -bg black -fg red -e 'nsec3walker-dicthashes ; bash'" },
    { "nsec3walker-query", "xterm -bg black -fg red -e 'nsec3walker-query ; bash'" },
    { "nsec3walker-randomhashes", "xterm -bg black -fg red -e 'nsec3walker-randomhashes ; bash'" },
    { "nsec3walker-unhash", "xterm -bg black -fg red -e 'nsec3walker-unhash ; bash'" },
    { "pastenum", "xterm -bg black -fg red -e 'pastenum -h ; bash'" },
    { "recon-ng", "xterm -bg black -fg red -e 'cd /usr/share/recon-ng ; ./recon-ng -h ; bash'" },
    { "rifiuti", "xterm -bg black -fg red -e 'rifiuti --help-all ; bash'" },
    { "rifiuti-vista", "xterm -bg black -fg red -e 'rifiuti-vista -h ; bash'" },
    { "ripdc", "xterm -bg black -fg red -e 'ripdc -H ; bash'" },
    { "sctpscan", "xterm -bg black -fg red -e 'sctpscan -h ; bash'" },
    { "smtp-user-enum", "xterm -bg black -fg red -e 'smtp-user-enum.pl ; bash'" },
    { "snmpcheck", "xterm -bg black -fg red -e 'snmpcheck-nothink -h ; bash'" },
    { "spiderfoot", "xterm -bg black -fg red -e 'spiderfoot ; bash'" },
    { "subdomainer", "xterm -bg black -fg red -e 'subdomainer.py -h ; bash'" },
    { "theharvester", "xterm -bg black -fg red -e 'theharvester ; bash'" },
    { "twofi", "xterm -bg black -fg red -e 'twofi --help ; bash'" },
    { "whatweb", "xterm -bg black -fg red -e 'whatweb -h ; bash'" },
}

reversingmenu = {
    { "d2j-apk-sign", "xterm -bg black -fg red -e 'd2j-apk-sign ; bash'" },
    { "d2j-asm-verify", "xterm -bg black -fg red -e 'd2j-asm-verify ; bash'" },
    { "d2j-decrpyt-string", "xterm -bg black -fg red -e 'd2j-decrpyt-string ; bash'" },
    { "d2j-dex-asmifier", "xterm -bg black -fg red -e 'd2j-dex-asmifier ; bash'" },
    { "d2j-dex-dump", "xterm -bg black -fg red -e 'd2j-dex-dump ; bash'" },
    { "d2j-dex2jar", "xterm -bg black -fg red -e 'd2j-dex2jar ; bash'" },
    { "d2j-init-deobf", "xterm -bg black -fg red -e 'd2j-init-deobf ; bash'" },
    { "d2j-jar-access", "xterm -bg black -fg red -e 'd2j-jar-access ; bash'" },
    { "d2j-jar-remap", "xterm -bg black -fg red -e 'd2j-jar-remap ; bash'" },
    { "d2j-jar2dex", "xterm -bg black -fg red -e 'd2j-jar2dex ; bash'" },
    { "d2j-jar2jasmin", "xterm -bg black -fg red -e 'd2j-jar2jasmin ; bash'" },
    { "d2j-jasmin2jar", "xterm -bg black -fg red -e 'd2j-jasmin2jar ; bash'" },
    { "edb", "edb" },
    { "flasm", "xterm -bg black -fg red -e 'flasm -h ; bash'" },
    { "javasnoop", "javasnoop" },
    { "jd-gui", "jd-gui" },
    { "js-beautify", "xterm -bg black -fg red -e 'js-beautify -h ; bash'" },
    { "packerid", "xterm -bg black -fg red -e 'packerid -h ; bash'" },
    { "ofs2rva", "xterm -bg black -fg red -e 'ofs2rva ; bash'" },
    { "pedis", "xterm -bg black -fg red -e 'pedis ; bash'" },
    { "pehash", "xterm -bg black -fg red -e 'pehash ; bash'" },
    { "pepack", "xterm -bg black -fg red -e 'pepack ; bash'" },
    { "pescan", "xterm -bg black -fg red -e 'pescan ; bash'" },
    { "pesec", "xterm -bg black -fg red -e 'pesec ; bash'" },
    { "pestr", "xterm -bg black -fg red -e 'pestr ; bash'" },
    { "readpe", "xterm -bg black -fg red -e 'readpe ; bash'" },
    { "rva2ofs", "xterm -bg black -fg red -e 'rva2ofs ; bash'" },
    { "r2", "xterm -bg black -fg red -e 'r2 -h ; bash'" },
    { "r2agent", "xterm -bg black -fg red -e 'r2agent -h ; bash'" },
    { "rabin2", "xterm -bg black -fg red -e 'rabin2 -h ; bash'" },
    { "radare2", "xterm -bg black -fg red -e 'radare2 -h ; bash'" },
    { "radiff2", "xterm -bg black -fg red -e 'radiff2 -h ; bash'" },
    { "rafind2", "xterm -bg black -fg red -e 'rafind2 -h ; bash'" },
    { "ragg2", "xterm -bg black -fg red -e 'ragg2 -h ; bash'" },
    { "ragg2-cc", "xterm -bg black -fg red -e 'ragg2-cc -h ; bash'" },
    { "rahash2", "xterm -bg black -fg red -e 'rahash2 -h ; bash'" },
    { "rarun2", "xterm -bg black -fg red -e 'rarun2 -h ; bash'" },
    { "rasm2", "xterm -bg black -fg red -e 'rasm2 -h ; bash'" },
    { "rax2", "xterm -bg black -fg red -e 'rax2 ; bash'" },
    { "RecStudio4CLI", "xterm -bg black -fg red -e 'cd /opt/recstudio/bin ; ./RecStudio4CLI ; bash'" },
    { "RecStudioLinux", "xterm -bg black -fg red -e 'cd /opt/recstudio/bin ; ./RecStudioLinux ; bash'" },
    { "recstudio", "recstudio" },
    { "gameconqueror", "gameconqueror" },
    { "scanmem", "xterm -bg black -fg red -e 'scanmem -h ; bash'" },
    { "swfintruder", "xterm -bg black -fg red -e 'cd /usr/share/swfintruder ; ls ; bash'" },
    { "udis86", "xterm -bg black -fg red -e 'udcli -h ; bash'" },
    { "vdbbin", "xterm -bg black -fg red -e 'vdbbin -h ; bash'" },
    { "vivbin", "xterm -bg black -fg red -e 'vivbin -h ; bash'" },
    { "zerowine", "xterm -bg black -fg red -e 'cd /usr/share/zerowine ; ls ; bash'" },
}

scannermenu = {
    { "admsnmp", "xterm -bg black -fg red -e 'admsnmp ; bash'" },
    { "allthevhosts", "xterm -bg black -fg red -e 'allthevhosts ; bash'" },
    { "asp-audit", "xterm -bg black -fg red -e 'asp-audit ; bash'" },
    { "bluelog", "xterm -bg black -fg red -e 'bluelog -h ; bash'" },
    { "braa", "xterm -bg black -fg red -e 'braa -h ; bash'" },
    { "bss", "xterm -bg black -fg red -e 'sudo bss ; bash'" },
    { "btscanner", "xterm -bg black -fg red -e 'btscanner --help ; bash'" },
    { "burpsuite", "burpsuite" },
    { "canari", "xterm -bg black -fg red -e 'canari ; bash'" },
    { "dispatcher", "xterm -bg black -fg red -e 'dispatcher ; bash'" },
    { "pysudo", "xterm -bg black -fg red -e 'pysudo ; bash'" },
    { "casefile", "casefile" },
    { "checksec", "xterm -bg black -fg red -e 'checksec --help ; bash'" },
    { "cisco-auditing-tool", "xterm -bg black -fg red -e 'cisco-auditing-tool ; bash'" },
    { "cisco-torch", "xterm -bg black -fg red -e 'cisco-torch ; bash'" },
    { "ciscos", "xterm -bg black -fg red -e 'ciscos ; bash'" },
    { "httsquash", "xterm -bg black -fg red -e 'httsquash ; bash'" },
    { "letdown", "xterm -bg black -fg red -e 'letdown ; bash'" },
    { "reverseraider", "xterm -bg black -fg red -e 'reverseraider ; bash'" },
    { "conscan", "xterm -bg black -fg red -e 'conscan -h ; bash'" },
    { "cookie-cadger", "xterm -bg black -fg red -e 'cookie-cadger ; bash'" },
    { "creepy", "creepy" },
    { "davtest", "xterm -bg black -fg red -e 'davtest ; bash'" },
    { "deblaze", "xterm -bg black -fg red -e 'deblaze ; bash'" },
    { "dhcpig", "xterm -bg black -fg red -e 'dhcpig -h ; bash'" },
    { "dirb", "xterm -bg black -fg red -e 'dirb ; bash'" },
    { "dirbuster", "dirbuster" },
    { "dmitry", "xterm -bg black -fg red -e 'dmitry ; bash'" },
    { "dnmap_client", "xterm -bg black -fg red -e 'dnmap_client -h ; bash'" },
    { "dnmap_server", "xterm -bg black -fg red -e 'dnmap_server -h ; bash'" },
    { "dnsa", "xterm -bg black -fg red -e 'dnsa ; bash'" },
    { "dnsbf", "xterm -bg black -fg red -e 'dnsbf ; bash'" },
    { "dnsenum", "xterm -bg black -fg red -e 'dnsenum.pl -h ; bash'" },
    { "dnsgoblin", "xterm -bg black -fg red -e 'dnsgoblin ; bash'" },
    { "dnspredict", "xterm -bg black -fg red -e 'sudo dnspredict --help ; bash'" },
    { "dnsspider", "xterm -bg black -fg red -e 'dnsspider -h ; bash'" },
    { "dnswalk", "xterm -bg black -fg red -e 'dnswalk --help ; bash'" },
    { "dpscan", "xterm -bg black -fg red -e 'dpscan ; bash'" },
    { "driftnet", "driftnet" },
    { "dripper", "xterm -bg black -fg red -e 'dripper -h ; bash'" },
    { "enum4linux", "xterm -bg black -fg red -e 'enum4linux ; bash'" },
    { "enumiax", "xterm -bg black -fg red -e 'enumiax ; bash'" },
    { "fierce", "xterm -bg black -fg red -e 'fierce.pl -h ; bash'" },
    { "firewalk", "xterm -bg black -fg red -e 'firewalk -h ; bash'" },
    { "flawfinder", "xterm -bg black -fg red -e 'flawfinder -h ; bash'" },
    { "ftpmap", "xterm -bg black -fg red -e 'ftpmap -h ; bash'" },
    { "ghost-phisher", "ghost-phisher" },
    { "grepforrfi", "xterm -bg black -fg red -e 'grepforrfi ; bash'" },
    { "gsa", "xterm -bg black -fg red -e 'gsad -h ; bash'" },
    { "gsd", "xterm -bg black -fg red -e 'gsd -h ; bash'" },
    { "halberd", "xterm -bg black -fg red -e 'halberd -h ; bash'" },
    { "hexorbase", "hexorbase" },
    { "http-enum", "xterm -bg black -fg red -e 'http-enum -h ; bash'" },
    { "hwk", "xterm -bg black -fg red -e 'hawk --help ; bash'" },
    { "hwk", "xterm -bg black -fg red -e 'hwk-eagle --help ; bash'" },
    { "icmpquery", "xterm -bg black -fg red -e 'icmpquery ; bash'" },
    { "ike-scan", "xterm -bg black -fg red -e 'ike-scan -h ; bash'" },
    { "psk-crack", "xterm -bg black -fg red -e 'psk-crack -h ; bash'" },
    { "inguma", "xterm -bg black -fg red -e 'sudo inguma ; bash'" },
    { "ipscan", "ipscan" },
    { "jigsaw", "xterm -bg black -fg red -e 'jigsaw -h ; bash'" },
    { "jsql", "jsql" },
    { "ldapenum", "xterm -bg black -fg red -e 'ldapenum.pl ; bash'" },
    { "lynis", "xterm -bg black -fg red -e 'sudo lynis -h ; bash'" },
    { "maltego", "maltego" },
    { "masscan", "xterm -bg black -fg red -e 'masscan --help ; bash'" },
    { "msfbinscan", "xterm -bg black -fg red -e 'msfbinscan -h ; bash'" },
    { "msfcli", "xterm -bg black -fg red -e 'msfcli -h ; bash'" },
    { "msfconsole", "xterm -bg black -fg red -e 'msfconsole ; bash'" },
    { "msfd", "xterm -bg black -fg red -e 'msfd ; bash'" },
    { "msfelfscan", "xterm -bg black -fg red -e 'msfelfscan -h ; bash'" },
    { "msfencode", "xterm -bg black -fg red -e 'msfencode -h ; bash'" },
    { "msfmachscan", "xterm -bg black -fg red -e 'msfmachscan -h ; bash'" },
    { "msfpayload", "xterm -bg black -fg red -e 'msfpayload -h ; bash'" },
    { "msfpescan", "xterm -bg black -fg red -e 'msfpescan -h ; bash'" },
    { "msfrop", "xterm -bg black -fg red -e 'msfrop -h ; bash'" },
    { "msfrpc", "xterm -bg black -fg red -e 'msfrpc -h ; bash'" },
    { "msfrpcd", "xterm -bg black -fg red -e 'msfrpcd -h ; bash'" },
    { "msfupdate", "xterm -bg black -fg red -e 'msfupdate -h ; bash'" },
    { "msfvenom", "xterm -bg black -fg red -e 'msfvenom -h ; bash'" },
    { "msf_exec.py", "xterm -bg black -fg red -e 'msf_exec.py ; bash'" },
    { "miranda-upnp", "xterm -bg black -fg red -e 'miranda-upnp -h ; bash'" },
    { "miranda-upnp-portmapper", "xterm -bg black -fg red -e 'miranda-upnp-portmapper ; bash'" },
    { "mssqlscan", "xterm -bg black -fg red -e 'mssqlscan ; bash'" },
    { "dnscat", "xterm -bg black -fg red -e 'dnscat -h ; bash'" },
    { "dnslogger", "xterm -bg black -fg red -e 'dnslogger -h ; bash'" },
    { "dnstest", "xterm -bg black -fg red -e 'dnstest -h ; bash'" },
    { "dnsxss", "xterm -bg black -fg red -e 'dnsxss -h ; bash'" },
    { "nbquery", "xterm -bg black -fg red -e 'nbquery -h ; bash'" },
    { "nbsniff", "xterm -bg black -fg red -e 'nbsniff -h ; bash'" },
    { "nikto", "xterm -bg black -fg red -e 'nikto -H ; bash'" },
    { "nmbscan", "xterm -bg black -fg red -e 'nmbscan ; bash'" },
    { "onesixtyone", "xterm -bg black -fg red -e 'onesixtyone ; bash'" },
    { "openvas-administrator", "xterm -bg black -fg red -e 'openvas-openvasad -h ; bash'" },
    { "check_omp", "xterm -bg black -fg red -e 'check_omp -h ; bash'" },
    { "omp", "xterm -bg black -fg red -e 'omp --help ; bash'" },
    { "omp-dialog", "xterm -bg black -fg red -e 'omp-dialog --help ; bash'" },
    { "openvas-client", "OpenVAS-Client" },
    { "greenbone-certdata-sync", "xterm -bg black -fg red -e 'greenbone-certdata-sync -h ; bash'" },
    { "greenbone-scapdata-sync", "xterm -bg black -fg red -e 'greenbone-scapdata-sync -h ; bash'" },
    { "openvas-certdata-sync", "xterm -bg black -fg red -e 'openvas-certdata-sync -h ; bash'" },
    { "openvas-scapdata-sync", "xterm -bg black -fg red -e 'openvas-scapdata-sync -h ; bash'" },
    { "openvasmd", "xterm -bg black -fg red -e 'openvasmd -h ; bash'" },
    { "greenbone-nvt-sync", "xterm -bg black -fg red -e 'greenbone-nvt-sync -h ; bash'" },
    { "openvas-adduser", "xterm -bg black -fg red -e 'openvas-adduser -h ; bash'" },
    { "openvas-mkcert", "xterm -bg black -fg red -e 'openvas-mkcert -h ; bash'" },
    { "openvas-mkcert-client", "xterm -bg black -fg red -e 'openvas-mkcert-client -h ; bash'" },
    { "openvas-nvt-sync", "xterm -bg black -fg red -e 'openvas-nvt-sync -h ; bash'" },
    { "openvas-rmuser", "xterm -bg black -fg red -e 'openvas-rmuser -h ; bash'" },
    { "openvassd", "xterm -bg black -fg red -e 'openvassd -h ; bash'" },
    { "minewt", "xterm -bg black -fg red -e 'minewt -h; bash'" },
    { "paketto-lc", "xterm -bg black -fg red -e 'sudo paketto-lc -h ; bash'" },
    { "paratrace", "xterm -bg black -fg red -e 'sudo paratrace -h ; bash'" },
    { "phentropy", "xterm -bg black -fg red -e 'phentropy -h ; bash'" },
    { "scanrand", "xterm -bg black -fg red -e 'sudo scanrand -h ; bash'" },
    { "ipsort", "xterm -bg black -fg red -e 'ipsort --help ; bash'" },
    { "pnscan", "xterm -bg black -fg red -e 'pnscan -h ; bash'" },
    { "propecia", "xterm -bg black -fg red -e 'propecia ; bash'" },
    { "ratproxy", "xterm -bg black -fg red -e 'ratproxy -h ; bash'" },
    { "rawr", "xterm -bg black -fg red -e 'rawr ; bash'" },
    { "redfang", "xterm -bg black -fg red -e 'redfang --help ; bash'" },
    { "relay-scanner", "xterm -bg black -fg red -e 'relay-scanner -help ; bash'" },
    { "ripdc", "xterm -bg black -fg red -e 'ripdc -H ; bash'" },
    { "scanssh", "xterm -bg black -fg red -e 'scanssh -h ; bash'" },
    { "sctpscan", "xterm -bg black -fg red -e 'sctpscan ; bash'" },
    { "sfscandiff", "xterm -bg black -fg red -e 'skscandiff -h ; bash'" },
    { "skipfish", "xterm -bg black -fg red -e 'skipfish -h ; bash'" },
    { "smtp-user-enum", "xterm -bg black -fg red -e 'smtp-user-enum.pl ; bash'" },
    { "smtp-vrfy", "xterm -bg black -fg red -e 'smtp-vrfy ; bash'" },
    { "snmpenum", "xterm -bg black -fg red -e 'snmpenum ; bash'" },
    { "snmpscan", "xterm -bg black -fg red -e 'snmpscan -h ; bash'" },
    { "sslcaudit", "xterm -bg black -fg red -e 'sslcaudit -h ; bash'" },
    { "sslscan", "xterm -bg black -fg red -e 'sslscan ; bash'" },
    { "subdomainer", "xterm -bg black -fg red -e 'subdomainer.py -h ; bash'" },
    { "synscan", "xterm -bg black -fg red -e 'sslog -h ; bash'" },
    { "synscan", "xterm -bg black -fg red -e 'synscan -h ; bash'" },
    { "tiger", "xterm -bg black -fg red -e 'tiger -h ; bash'" },
    { "tigercron", "xterm -bg black -fg red -e 'tigercron -h ; bash'" },
    { "tigexp", "xterm -bg black -fg red -e 'tigexp -h ; bash'" },
    { "getpermit", "xterm -bg black -fg red -e 'getpermit ; bash'" },
    { "realpath", "xterm -bg black -fg red -e 'realpath --help ; bash'" },
    { "tlssled", "xterm -bg black -fg red -e 'tlssled -h ; bash'" },
    { "unicornscan", "xterm -bg black -fg red -e 'unicornscan -h ; bash'" },
    { "uniscan", "xterm -bg black -fg red -e 'sudo uniscan --help ; bash'" },
    { "unix-privesc-check", "xterm -bg black -fg red -e 'unix-privesc-check ; bash'" },
    { "upnpscan", "xterm -bg black -fg red -e 'upnpscan -h ; bash'" },
    { "videosnarf", "xterm -bg black -fg red -e 'videosnarf ; bash'" },
    { "vulscan", "xterm -bg black -fg red -e 'cd /usr/share/nmap/scripts/vulscan ; ls ; bash'" },
    { "waffit", "xterm -bg black -fg red -e 'wafw00f -h ; bash'" },
    { "wapiti", "xterm -bg black -fg red -e 'wapiti -h ; bash'" },
    { "wapiti-cookie", "xterm -bg black -fg red -e 'wapiti-cookie -h ; bash'" },
    { "wapiti-getcookie", "xterm -bg black -fg red -e 'wapiti-getcookie -h ; bash'" },
    { "webenum", "xterm -bg black -fg red -e 'webenum -h ; bash'" },
    { "webrute", "xterm -bg black -fg red -e 'webrute.pl -help ; bash'" },
    { "webscarab", "webscarab" },
    { "webshag_cli", "xterm -bg black -fg red -e 'webshag_cli -h ; bash'" },
    { "webshag_gui", "webshag_gui" },
    { "websploit", "xterm -bg black -fg red -e 'websploit ; bash'" },
    { "wnmap", "xterm -bg black -fg red -e 'wnmap -h ; bash'" },
    { "wpscan", "xterm -bg black -fg red -e 'wpscan -h ; bash'" },
    { "yersinia", "xterm -bg black -fg red -e 'sudo yersinia -h ; bash'" },
    { "zmap", "xterm -bg black -fg red -e 'zmap -h ; bash'" },
}

sniffermenu = {
    { "cdpsnarf", "xterm -bg black -fg red -e 'cdpsnarf -h ; bash'" },
    { "driftnet", "xterm -bg black -fg red -e 'driftnet -h ; bash'" },
    { "hex2raw", "xterm -bg black -fg red -e 'hex2raw -h ; bash'" },
    { "hexinject", "xterm -bg black -fg red -e 'hexinject -h ; bash'" },
    { "prettypacket", "xterm -bg black -fg red -e 'prettypacket -h ; bash'" },
    { "mitmap", "xterm -bg black -fg red -e 'mitmap.sh ; bash'" },
    { "ashunt", "xterm -bg black -fg red -e 'sudo ashunt -h ; bash'" },
    { "bpfc", "xterm -bg black -fg red -e 'bpfc ; bash'" },
    { "ifpps", "xterm -bg black -fg red -e 'ifpps ; bash'" },
    { "p0f", "xterm -bg black -fg red -e 'p0f -h ; bash'" },
    { "p0f-client", "xterm -bg black -fg red -e 'p0f-client ; bash'" },
    { "p0f-sendsyn", "xterm -bg black -fg red -e 'p0f-sendsyn ; bash'" },
}

socialmenu = {
    { "creepy", "creepy" },
    { "jigsaw", "xterm -bg black -fg red -e 'jigsaw ; bash'" },
    { "seautomate", "xterm -bg black -fg red -e 'seautomate ; bash'" },
    { "seproxy", "xterm -bg black -fg red -e 'seproxy ; bash'" },
    { "setoolkit", "xterm -bg black -fg red -e 'setoolkit ; bash'" },
    { "seupdate", "xterm -bg black -fg red -e 'seupdate ; bash'" },
    { "seweb", "xterm -bg black -fg red -e 'seweb ; bash'" },
    { "websploit", "xterm -bg black -fg red -e 'websploit ; bash'" },
}

spoofmenu = {
    { "ADMdnsfuckr", "xterm -bg black -fg red -e 'ADMdnsfuckr ; bash'" },
    { "ADMkillDNS", "xterm -bg black -fg red -e 'ADMkillDNS ; bash'" },
    { "ADMnOg00d", "xterm -bg black -fg red -e 'ADMnOg00d ; bash'" },
    { "ADMsnOOfID", "xterm -bg black -fg red -e 'ADMsnOOfID ; bash'" },
    { "ADMsniffID", "xterm -bg black -fg red -e 'ADMsniffID ; bash'" },
    { "arpoison", "xterm -bg black -fg red -e 'sudo arpoison -h ; bash'" },
    { "fakedns", "xterm -bg black -fg red -e 'sudo fakedns ; bash'" },
    { "inundator", "xterm -bg black -fg red -e 'inundator ; bash'" },
    { "lans", "xterm -bg black -fg red -e 'lans -h ; bash'" },
    { "lsrtunnel", "xterm -bg black -fg red -e 'sudo lsrtunnel ; bash'" },
    { "multimac", "xterm -bg black -fg red -e 'multimac -h ; bash'" },
    { "nbnspoof", "xterm -bg black -fg red -e 'nbnspoof.py ; bash'" },
    { "netcommander", "xterm -bg black -fg red -e 'netcmd -h ; bash'" },
    { "pyminifakedns", "xterm -bg black -fg red -e 'sudo pyminifakedns ; bash'" },
    { "sergio-proxy", "xterm -bg black -fg red -e 'sergio-proxy -h ; bash'" },
}

threatmodelmenu = {
    { "magictree", "magictree" },
}

tunnelmenu = {
    { "chownat", "xterm -bg black -fg red -e 'chownat -h ; bash'" },
    { "ctunnel", "xterm -bg black -fg red -e 'ctunnel -h ; bash'" },
    { "dns2tcpc", "xterm -bg black -fg red -e 'dns2tcpc ; bash'" },
    { "dns2tcpd", "xterm -bg black -fg red -e 'dns2tcpd ; bash'" },
    { "icmptx", "xterm -bg black -fg red -e 'sudo icmptx ; bash'" },
    { "iodine", "xterm -bg black -fg red -e 'iodine ; bash'" },
    { "iodined", "xterm -bg black -fg red -e 'iodined ; bash'" },
    { "matahari", "xterm -bg black -fg red -e 'matahari ; bash'" },
    { "ptunnel", "xterm -bg black -fg red -e 'ptunnel -h ; bash'" },
    { "udptunnel", "xterm -bg black -fg red -e 'udptunnel -h ; bash'" },
}

unpackermenu = {
    { "js-beautify", "xterm -bg black -fg red -e 'js-beautify ; bash'" },
}

voipmenu = {
    { "ace", "xterm -bg black -fg red -e 'ace -h ; bash'" },
    { "erase-registrations", "xterm -bg black -fg red -e 'erase_registrations ; bash'" },
    { "iaxflood", "xterm -bg black -fg red -e 'iaxflood ; bash'" },
    { "pcapsipdump", "xterm -bg black -fg red -e 'pcapsipdump ; bash'" },
    { "redirectpoison", "xterm -bg black -fg red -e 'redirectpoison ; bash'" },
    { "rtp-flood", "xterm -bg black -fg red -e 'rtpflood -h ; bash'" },
    { "siparmyknife", "xterm -bg black -fg red -e 'siparmyknife ; bash'" },
    { "sipcrack", "xterm -bg black -fg red -e 'sipcrack -h ; bash'" },
    { "sipdump", "xterm -bg black -fg red -e 'sipdump -h ; bash'" },
    { "sipp", "xterm -bg black -fg red -e 'sipp ; bash'" },
    { "sipsak", "xterm -bg black -fg red -e 'sipsak ; bash'" },
    { "teardown", "xterm -bg black -fg red -e 'teardown ; bash'" },
    { "vnak", "xterm -bg black -fg red -e 'vnak ; bash'" },
    { "voiper", "xterm -bg black -fg red -e 'cd /usr/share/voiper ; ls ; bash'" },
    { "voiphopper", "xterm -bg black -fg red -e 'voiphopper ; bash'" },
    { "voipctl", "xterm -bg black -fg red -e 'voipctl -h ; bash'" },
    { "voipong", "xterm -bg black -fg red -e 'voipong -h ; bash'" },
}

webappmenu = {
    { "allthevhosts", "xterm -bg black -fg red -e 'allthevhosts ; bash'" },
    { "asp-audit", "xterm -bg black -fg red -e 'asp-audit ; bash'" },
    { "bbqsql", "xterm -bg black -fg red -e 'bbqsql -h ; bash'" },
    { "blindelephant", "xterm -bg black -fg red -e 'blindelephant -h ; bash'" },
    { "bsqlbf", "xterm -bg black -fg red -e 'bsqlbf.pl ; bash'" },
    { "burpsuite", "burpsuite" },
    { "cms-explorer", "xterm -bg black -fg red -e 'cms-explorer -h ; bash'" },
    { "csrftester", "csrftester" },
    { "darkd0rk3r", "xterm -bg black -fg red -e 'darkd0rk3r ; bash'" },
    { "darkjumper", "xterm -bg black -fg red -e 'cd /usr/share/darkjumper ; ls ; bash'" },
    { "darkmysqli", "xterm -bg black -fg red -e 'darkmysqli -h ; bash'" },
    { "dff-scanner", "xterm -bg black -fg red -e 'cd /usr/share/dff-scanner ; bash'" },
    { "dirb", "xterm -bg black -fg red -e 'dirb ; bash'" },
    { "dirbuster", "dirbuster" },
    { "easyfuzzer", "xterm -bg black -fg red -e 'easyfuzzer ; bash'" },
    { "easyfuzzer-proxy", "xterm -bg black -fg red -e 'easyfuzzer-proxy ; bash'" },
    { "easyfuzzer-proxy-misc", "xterm -bg black -fg red -e 'easyfuzzer-proxy-misc ; bash'" },
    { "mycrawler2", "xterm -bg black -fg red -e 'mycrawler2 ; bash'" },
    { "prepare4easyfuzzer", "xterm -bg black -fg red -e 'prepare4easyfuzzer ; bash'" },
    { "prepare4easyfuzzer-misc", "xterm -bg black -fg red -e 'prepare4easyfuzzer-misc ; bash'" },
    { "prepare4sqlfuzzer", "xterm -bg black -fg red -e 'prepare4sqlfuzzer ; bash'" },
    { "sqlfuzzer", "xterm -bg black -fg red -e 'sqlfuzzer ; bash'" },
    { "sqlfuzzer-proxy", "xterm -bg black -fg red -e 'sqlfuzzer-proxy ; bash'" },
    { "wbxml2request", "xterm -bg black -fg red -e 'wbxml2request ; bash'" },
    { "wsdl2request", "xterm -bg black -fg red -e 'wsdl2request ; bash'" },
    { "golismero", "xterm -bg black -fg red -e 'golismero -h ; bash'" },
    { "grabber", "xterm -bg black -fg red -e 'grabber-scanner -h ; bash'" },
    { "gwtenum", "xterm -bg black -fg red -e 'gwtenum ; bash'" },
    { "gwtfuzzer", "xterm -bg black -fg red -e 'gwtfuzzer ; bash'" },
    { "gwtparse", "xterm -bg black -fg red -e 'gwtparse ; bash'" },
    { "halberd", "xterm -bg black -fg red -e 'halberd ; bash'" },
    { "isr-form", "xterm -bg black -fg red -e 'isr-form ; bash'" },
    { "joomscan", "xterm -bg black -fg red -e 'joomscan -h ; bash'" },
    { "kolkata", "xterm -bg black -fg red -e 'kolkata ; bash'" },
    { "laudanum", "xterm -bg black -fg red -e 'cd /usr/share/laudanum ; ls ; bash'" },
    { "list-urls", "xterm -bg black -fg red -e 'list-urls ; bash'" },
    { "metoscan", "xterm -bg black -fg red -e 'metoscan ; bash'" },
    { "multiinjector", "xterm -bg black -fg red -e 'python2 /usr/bin/MultiInjector.py ; bash'" },
    { "nikto", "xterm -bg black -fg red -e 'nikto -H ; bash'" },
    { "owtf", "xterm -bg black -fg red -e 'owtf ; bash'" },
    { "paros", "paros" },
    { "pblind", "xterm -bg black -fg red -e 'pblind.py ; bash'" },
    { "plecost", "xterm -bg black -fg red -e 'plecost ; bash'" },
    { "ratproxy", "xterm -bg black -fg red -e 'ratproxy -h ; bash'" },
    { "rawr", "xterm -bg black -fg red -e 'rawr -h ; bash'" },
    { "rww-attack", "xterm -bg black -fg red -e 'rww-attack ; bash'" },
    { "skipfish", "xterm -bg black -fg red -e 'skipfish -h ; bash'" },
    { "spike-proxy", "xterm -bg black -fg red -e 'spike-proxy -h ; bash'" },
    { "sqid", "xterm -bg black -fg red -e 'sqid -h ; bash'" },
    { "sqlbrute", "xterm -bg black -fg red -e 'python2 /usr/bin/sqlbrute.py ; bash'" },
    { "sqlmap", "xterm -bg black -fg red -e 'sqlmap -hh ; bash'" },
    { "sqlninja", "xterm -bg black -fg red -e 'sqlninja -h ; bash'" },
    { "sqlsus", "xterm -bg black -fg red -e 'sqlsus -h ; bash'" },
    { "uatester", "xterm -bg black -fg red -e 'uatester ; bash'" },
    { "uniscan", "xterm -bg black -fg red -e 'sudo uniscan -h ; bash'" },
    { "urlcrazy", "xterm -bg black -fg red -e 'urlcrazy -h ; bash'" },
    { "vega", "xterm -bg black -fg red -e 'vega ; bash'" },
    { "waffit", "xterm -bg black -fg red -e 'wafw00f -h ; bash'" },
    { "wapiti", "xterm -bg black -fg red -e 'wapiti -h ; bash'" },
    { "wapiti-cookie", "xterm -bg black -fg red -e 'wapiti-cookie -h ; bash'" },
    { "wapiti-getcookie", "xterm -bg black -fg red -e 'wapiti-getcookie -h ; bash'" },
    { "webacoo", "xterm -bg black -fg red -e 'webacoo -h ; bash'" },
    { "webenum", "xterm -bg black -fg red -e 'webenum ; bash'" },
    { "webhandler", "xterm -bg black -fg red -e 'webhandler ; bash'" },
    { "webrute", "xterm -bg black -fg red -e 'webrute.pl -help ; bash'" },
    { "webscarab", "webscarab" },
    { "webshag_cli", "xterm -bg black -fg red -e 'webshag_cli -h ; bash'" },
    { "webshag_gui", "webshag_gui" },
    { "webshells", "xterm -bg black -fg red -e 'cd /usr/share/webshells ; ls ; bash'" },
    { "webslayer", "webslayer" },
    { "weevely", "xterm -bg black -fg red -e 'weevely ; bash'" },
    { "wfuzz", "xterm -bg black -fg red -e 'wfuzz ; bash'" },
    { "whatweb", "xterm -bg black -fg red -e 'whatweb ; bash'" },
    { "wmat", "xterm -bg black -fg red -e 'wmat ; bash'" },
    { "wpscan", "xterm -bg black -fg red -e 'wpscan ; bash'" },
    { "wsfuzzer", "xterm -bg black -fg red -e 'wsfuzzer ; bash'" },
    { "xsser", "xterm -bg black -fg red -e 'xsser -h ; bash'" },
    { "xsss", "xterm -bg black -fg red -e 'xsss ; bash'" },
    { "zaproxy", "zaproxy" },
}

windowsmenu = {
    { "3proxy-win32", "xterm -bg black -fg red -e 'cd /usr/share/windows/3proxy-win32 ; ls ; bash'" },
    { "brutus", "xterm -bg black -fg red -e 'cd /usr/share/windows/brutus ; ls ; bash'" },
    { "creddump", "xterm -bg black -fg red -e 'cd /usr/share/windows/creddump ; ls ; bash'" },
    { "dumpacl", "xterm -bg black -fg red -e 'cd /usr/share/windows/dumpacl ; ls ; bash'" },
    { "fport", "xterm -bg black -fg red -e 'cd /usr/share/windows/fport ; ls ; bash'" },
    { "handle", "xterm -bg black -fg red -e 'cd /usr/share/windows/handle ; ls ; bash'" },
    { "httprint-win32", "xterm -bg black -fg red -e 'cd /usr/share/windows/httprint-win32 ; ls ; bash'" },
    { "hyperion", "xterm -bg black -fg red -e 'cd /usr/share/windows/hyperion ; ls ; bash'" },
    { "ikeprobe", "xterm -bg black -fg red -e 'cd /usr/share/windows/ikeprobe-latest ; ls ; bash'" },
    { "klogger", "xterm -bg black -fg red -e 'cd /usr/share/windows/klogger ; ls ; bash'" },
    { "mbenum", "xterm -bg black -fg red -e 'cd /usr/share/windows/mbenum-1.5.0 ; ls ; bash'" },
    { "nbtenum", "xterm -bg black -fg red -e 'cd /usr/share/windows/nbtenum ; ls ; bash'" },
    { "nishang", "xterm -bg black -fg red -e 'cd /usr/share/windows/nishang ; ls ; bash'" },
    { "ollydbg", "xterm -bg black -fg red -e 'ollydbg ; bash'" },
    { "orakelcrackert", "xterm -bg black -fg red -e 'cd /usr/share/windows/orakelcrackert ; ls ; bash'" },
    { "powersploit", "xterm -bg black -fg red -e 'cd /usr/share/windows/powersploit ; ls ; bash'" },
    { "pstoreview", "xterm -bg black -fg red -e 'cd /usr/share/windows/pstoreview ; ls ; bash'" },
    { "pwdump", "xterm -bg black -fg red -e 'cd /usr/share/windows/pwdump ; ls ; bash'" },
    { "sipscan", "xterm -bg black -fg red -e 'cd /usr/share/windows/sipscan ; ls ; bash'" },
    { "smbrelay", "xterm -bg black -fg red -e 'cd /usr/share/windows/smbrelay ; ls ; bash'" },
    { "snscan", "xterm -bg black -fg red -e 'cd /usr/share/windows/snscan ; ls ; bash'" },
    { "spade", "xterm -bg black -fg red -e 'cd /usr/share/windows/spade ; ls ; bash'" },
    { "sqlping", "xterm -bg black -fg red -e 'cd /usr/share/windows/sqlping ; ls ; bash" },
    { "superscan", "xterm -bg black -fg red -e 'cd /usr/share/windows/superscan-4 ; ls ; bash'" },
    { "sysinternals-suite", "xterm -bg black -fg red -e 'cd /usr/share/windows/sysinternals-suite ; ls ; bash'" },
    { "unsecure", "xterm -bg black -fg red -e 'cd /usr/share/windows/unsecure ; ls ; bash'" },
    { "winfo", "xterm -bg black -fg red -e 'cd /usr/share/windows/winfo ; ls ; bash'" },
    { "x-scan", "xterm -bg black -fg red -e 'cd /usr/share/windows/x-scan ; ls ; bash'" },
}

wirelessmenu = {
    { "airflood", "xterm -bg black -fg red -e 'sudo airflood -h ; bash'" },
    { "airopdate", "xterm -bg black -fg red -e 'sudo airopdate ; bash'" },
    { "airoscript-ng", "xterm -bg black -fg red -e 'sudo airoscript-ng ; bash'" },
    { "airoscwordlist", "xterm -bg black -fg red -e 'airoscwordlist ; bash'" },
    { "airpwn", "xterm -bg black -fg red -e 'airpwn -h ; bash'" },
    { "wep_keygen", "xterm -bg black -fg red -e 'wep_keygen ; bash'" },
    { "batctl", "xterm -bg black -fg red -e 'batctl ; bash'" },
    { "batman-adv", "xterm -bg black -fg red -e 'batman-adv ; bash'" },
    { "bully", "xterm -bg black -fg red -e 'bully -h ; bash'" },
    { "cowpatty", "xterm -bg black -fg red -e 'cowpatty -h ; bash'" },
    { "genpmk", "xterm -bg black -fg red -e 'genpmk -h ; bash'" },
    { "eapmd5pass", "xterm -bg black -fg red -e 'eapmd5pass ; bash'" },
    { "fern-wifi-cracker", "fern" },
    { "g72x++", "xterm -bg black -fg red -e 'decode-g72x -h ; bash'" },
    { "giskismet", "xterm -bg black -fg red -e 'giskismet ; bash'" },
    { "gqrx", "xterm -bg black -fg red -e 'gqrx ; bash'" },
    { "hotspotter", "xterm -bg black -fg red -e 'hotspotter ; bash'" },
    { "hawk", "xterm -bg black -fg red -e 'hawk --help ; bash'" },
    { "hwk-eagle", "xterm -bg black -fg red -e 'hwk-eagle --help ; bash'" },
    { "zbassocflood", "xterm -bg black -fg red -e 'zbassocflood ; bash'" },
    { "zbconvert", "xterm -bg black -fg red -e 'zbconvert ; bash'" },
    { "zbdsniff", "xterm -bg black -fg red -e 'zbdsniff ; bash'" },
    { "zbdump", "xterm -bg black -fg red -e 'zbdump ; bash'" },
    { "zbfind", "zbfind" },
    { "zbgoodfind", "xterm -bg black -fg red -e 'zbgoodfind ; bash'" },
    { "zbid", "xterm -bg black -fg red -e 'zbid ; bash'" },
    { "zbkey", "xterm -bg black -fg red -e 'zbkey ; bash'" },
    { "zbreplay", "xterm -bg black -fg red -e 'zbreplay ; bash'" },
    { "zbscapy", "xterm -bg black -fg red -e 'zbscapy ; bash'" },
    { "zbstumbler", "xterm -bg black -fg red -e 'zbstumbler -h ; bash'" },
    { "zbwireshark", "xterm -bg black -fg red -e 'zbwireshark ; bash'" },
    { "kismet-earth", "xterm -bg black -fg red -e 'cd /usr/share/kismet-earth ; ls ; bash'" },
    { "mdk3", "xterm -bg black -fg red -e 'sudo mdk3 --help ; bash'" },
    { "mfcuk", "xterm -bg black -fg red -e 'mfcuk ; bash'" },
    { "mfoc", "xterm -bg black -fg red -e 'mfoc -h ; bash'" },
    { "netdiscover", "xterm -bg black -fg red -e 'netdiscover -h ; bash'" },
    { "pyrit", "xterm -bg black -fg red -e 'pyrit -h ; bash'" },
    { "rfdump", "rfdump" },
    { "rfidiot-ChAP", "xterm -bg black -fg red -e 'rfidiot-ChAP -h ; bash'" },
    { "rfidiot-cardselect", "xterm -bg black -fg red -e 'rfidiot-cardselect -h ; bash'" },
    { "rfidiot-copytag", "xterm -bg black -fg red -e 'rfidiot-copytag -h ; bash'" },
    { "rfidiot-demotag", "xterm -bg black -fg red -e 'rfidiot-demotag -h ; bash'" },
    { "rfidiot-eeprom", "xterm -bg black -fg red -e 'rfidiot-eeprom -h ; bash'" },
    { "rfidiot-fdxbnum", "xterm -bg black -fg red -e 'rfidiot-fdxbnum -h ; bash'" },
    { "rfidiot-formatmifare1kvalue", "xterm -bg black -fg red -e 'rfidiot-formatmifare1kvalue -h ; bash'" },
    { "rfidiot-froschtest", "xterm -bg black -fg red -e 'rfidiot-froschtest -h ; bash'" },
    { "rfidiot-hidprox", "xterm -bg black -fg red -e 'rfidiot-hidprox -h ; bash'" },
    { "rfidiot-hitag2brute", "xterm -bg black -fg red -e 'rfidiot-hitag2brute -h ; bash'" },
    { "rfidiot-hitag2reset", "xterm -bg black -fg red -e 'rfidiot-hitag2reset -h ; bash'" },
    { "rfidiot-isotype", "xterm -bg black -fg red -e 'rfidiot-isotype -h ; bash'" },
    { "rfidiot-jcopmifare", "xterm -bg black -fg red -e 'rfidiot-jcopmifare -h; bash'" },
    { "rfidiot-jcopsetatrhist", "xterm -bg black -fg red -e 'rfidiot-jcopsetatrhist -h ; bash'" },
    { "rfidiot-jcoptool", "xterm -bg black -fg red -e 'rfidiot-jcoptool -h ; bash'" },
    { "rfidiot-lfxtype", "xterm -bg black -fg red -e 'rfidiot-lfxtype -h ; bash'" },
    { "rfidiot-loginall", "xterm -bg black -fg red -e 'rfidiot-loginall -h ; bash'" },
    { "rfidiot-mifarekeys", "xterm -bg black -fg red -e 'rfidiot-mifarekeys -h ; bash'" },
    { "rfidiot-mrpkey", "xterm -bg black -fg red -e 'rfidiot-mrpkey -h ; bash'" },
    { "rfidiot-multiselect", "xterm -bg black -fg red -e 'rfidiot-multiselect -h ; bash'" },
    { "rfidiot-pn532emulate", "xterm -bg black -fg red -e 'rfidiot-pn532emulate -h; bash'" },
    { "rfidiot-pn532mitm", "xterm -bg black -fg red -e 'rfidiot-pn532mitm -h ; bash'" },
    { "rfidiot-q5reset", "xterm -bg black -fg red -e 'rfidiot-q5reset -h ; bash'" },
    { "rfidiot-readlfx", "xterm -bg black -fg red -e 'rfidiot-readlfx -h ; bash'" },
    { "rfidiot-readmifare1k", "xterm -bg black -fg red -e 'rfidiot-readmifare1k -h ; bash'" },
    { "rfidiot-readmifaresimple", "xterm -bg black -fg red -e 'rfidiot-readmifaresimple -h ; bash'" },
    { "rfidiot-readmifareultra", "xterm -bg black -fg red -e 'rfidiot-readmifareultra -h ; bash'" },
    { "rfidiot-readtag", "xterm -bg black -fg red -e 'rfidiot-readtag -h ; bash'" },
    { "rfidiot-rfidiot-cli", "xterm -bg black -fg red -e 'rfidiot-rfidiot-cli -h ; bash'" },
    { "rfidiot-send-apdu", "xterm -bg black -fg red -e 'rfidiot-send-apdu -h ; bash'" },
}

blackarchmenu = {
    { "anti-forensic", antiforensicmenu },
    { "automation", automationmenu },
    { "backdoor", backdoormenu },
    { "binary", binarymenu },
    { "bluetooth", bluetoothmenu },
    { "code-audit", codeauditmenu },
    { "cracker", crackermenu },
    { "crypto", cryptomenu },
    { "database", databasemenu },
    { "debugger", debuggermenu },
    { "decompiler", decompilermenu },
    { "defensive", defensivemenu },
    { "disassembler", disassemblermenu },
    { "dos", dosmenu },
    { "drone", dronemenu },
    { "exploitation", exploitationmenu },
    { "fingerprint", fingerprintmenu },
    { "forensic", forensicmenu },
    { "fuzzer", fuzzermenu },
    { "hardware", hardwaremenu },
    { "honeypot", honeypotmenu },
    { "malware", malwaremenu },
    { "misc", miscmenu },
    { "mobile", mobilemenu },
    { "networking", networkingmenu },
    { "nfc", nfcmenu },
    { "packer", packermenu },
    { "proxy", proxymenu },
    { "recon", reconmenu },
    { "reversing", reversingmenu },
    { "scanner", scannermenu },
    { "sniffer", sniffermenu },
    { "social", socialmenu },
    { "spoof", spoofmenu },
    { "threat-model", threatmodelmenu },
    { "tunnel", tunnelmenu },
    { "unpacker", unpackermenu },
    { "voip", voipmenu },
    { "webapp", webappmenu },
    { "windows", windowsmenu },
    { "wireless", wirelessmenu },
}

mymainmenu = awful.menu({
items = {
		{ "awesome", myawesomemenu, beautiful.awesome_icon },
		{ "terminals", xtermmenu },
		{ "browsers", browsermenu },
        { "blackarch", blackarchmenu }
	}
})

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock()

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mylauncher)
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then right_layout:add(wibox.widget.systray()) end
    right_layout:add(mytextclock)
    right_layout:add(mylayoutbox[s])

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        local tag = awful.tag.gettags(screen)[i]
                        if tag then
                           awful.tag.viewonly(tag)
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      local tag = awful.tag.gettags(screen)[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.movetotag(tag)
                          end
                     end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.toggletag(tag)
                          end
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][2] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- buttons for the titlebar
        local buttons = awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
                )

        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))
        left_layout:buttons(buttons)

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local middle_layout = wibox.layout.flex.horizontal()
        local title = awful.titlebar.widget.titlewidget(c)
        title:set_align("center")
        middle_layout:add(title)
        middle_layout:buttons(buttons)

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(middle_layout)

        awful.titlebar(c):set_widget(layout)
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
