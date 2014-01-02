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
beautiful.init("/usr/share/awesome/themes/default/theme.lua")

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
    { "secure-delete", "secure-delete" },
}

automationmenu = {
    { "cewl", "cewl" },
    { "checksec", "checksec" },
    { "crunch", "crunch" },
    { "gooscan", "gooscan" },
    { "hackersh", "hackersh" },
    { "mitmap", "mitmap" },
    { "nfspy", "nfspy" },
    { "nfsshell", "nfsshell" },
    { "panoptic", "panoptic" },
    { "rsmangler", "rsmangler" },
    { "sakis3g", "sakis3g" },
    { "simple-ducky", "simple-ducky" },
    { "sipvicious", "sipvicious" },
    { "sploitctl", "sploitctl" },
    { "tiger", "tiger" },
    { "tlssled", "tlssled" },
    { "unix-privesc-check", "unix-privesc-check" },
    { "username-anarchy", "username-anarchy" },
    { "voiphopper", "voiphopper" },
    { "wiffy", "wiffy" },
    { "wnmap", "wnmap" },
}

backdoormenu = {
    { "backdoor-factory", "backdoor-factory" },
    { "cymothoa", "cymothoa" },
    { "enyelkm", "enyelkm" },
    { "hotpatch", "hotpatch" },
    { "jynx2", "jynx2" },
    { "ms-sys", "ms-sys" },
    { "rrs", "rrs" },
    { "rubilyn", "rubilyn" },
    { "trixd00r", "trixd00r" },
    { "tsh", "tsh" },
    { "webacoo", "webacoo" },
    { "webshells", "webshells" },
    { "weevely", "weevely" },
}

binarymenu = {
    { "backdoor-factory", "backdoor-factory" },
    { "binwally", "binwally" },
    { "ms-sys", "ms-sys" },
    { "packerid", "packerid" },
}

bluetoothmenu = {
    { "bluebugger", "bluebugger" },
    { "bluelog", "bluelog" },
    { "bluepot", "bluepot" },
    { "blueprint", "blueprint" },
    { "bluesnarfer", "bluesnarfer" },
    { "braces", "braces" },
    { "bss", "bss" },
    { "bt_audit", "bt_audit" },
    { "btcrack", "btcrack" },
    { "btscanner", "btscanner" },
    { "carwhisperer", "carwhisperer" },
    { "ghettotooth", "ghettotooth" },
    { "hidattack", "hidattack" },
    { "obexstress", "obexstress" },
    { "redfang", "redfang" },
    { "spooftooph", "spooftooph" },
    { "tbear", "tbear" },
    { "ubertooth", "ubertooth" },
}

codeauditmenu = {
    { "flawfinder", "flawfinder" },
    { "pscan", "pscan" },
}

crackermenu = {
    { "acccheck", "acccheck" },
    { "aesfix", "aesfix" },
    { "aeskeyfind", "aeskeyfind" },
    { "against", "against" },
    { "asleap", "asleap" },
    { "beleth", "beleth" },
    { "bios_memimage", "bios_memimage" },
    { "blackhash", "blackhash" },
    { "bob-the-butcher", "bob-the-butcher" },
    { "brutessh", "brutessh" },
    { "btcrack", "btcrack" },
    { "bully", "bully" },
    { "cewl", "cewl" },
    { "cisco-auditing-tool", "cisco-auditing-tool" },
    { "cisco-ocs", "cisco-ocs" },
    { "cmospwd", "cmospwd" },
    { "cowpatty", "cowpatty" },
    { "creddump", "creddump" },
    { "crunch", "crunch" },
    { "cupp", "cupp" },
    { "dbpwaudit", "dbpwaudit" },
    { "dpeparser", "dpeparser" },
    { "eapmd5pass", "eapmd5pass" },
    { "enabler", "enabler" },
    { "evilmaid", "evilmaid" },
    { "fang", "fang" },
    { "fern-wifi-cracker", "fern-wifi-cracker" },
    { "findmyhash", "findmyhash" },
    { "hashcat", "hashcat" },
    { "hashcat-utils", "hashcat-utils" },
    { "hashtag", "hashtag" },
    { "hydra", "hydra" },
    { "iheartxor", "iheartxor" },
    { "ikecrack", "ikecrack" },
    { "inguma", "inguma" },
    { "jbrute", "jbrute" },
    { "johnny", "johnny" },
    { "keimpx", "keimpx" },
    { "lodowep", "lodowep" },
    { "maskprocessor", "maskprocessor" },
    { "masscan", "masscan" },
    { "mdcrack", "mdcrack" },
    { "medusa", "medusa" },
    { "mfoc", "mfoc" },
    { "morxbrute", "morxbrute" },
    { "onesixtyone", "onesixtyone" },
    { "owabf", "owabf" },
    { "pack", "pack" },
    { "passcracking", "passcracking" },
    { "patator", "patator" },
    { "pdfcrack", "pdfcrack" },
    { "pdgmail", "pdgmail" },
    { "phoss", "phoss" },
    { "php-mt-seed", "php-mt-seed" },
    { "phrasendrescher", "phrasendrescher" },
    { "pipal", "pipal" },
    { "pyrit", "pyrit" },
    { "rainbowcrack", "rainbowcrack" },
    { "rarcrack", "rarcrack" },
    { "rcracki-mt", "rcracki-mt" },
    { "rdesktop-brute", "rdesktop-brute" },
    { "reaver", "reaver" },
    { "rootbrute", "rootbrute" },
    { "rsakeyfind", "rsakeyfind" },
    { "samdump2", "samdump2" },
    { "samydeluxe", "samydeluxe" },
    { "sidguesser", "sidguesser" },
    { "sipcrack", "sipcrack" },
    { "smbbf", "smbbf" },
    { "sqlpat", "sqlpat" },
    { "ssh-privkey-crack", "ssh-privkey-crack" },
    { "sshatter", "sshatter" },
    { "sshtrix", "sshtrix" },
    { "sslnuke", "sslnuke" },
    { "statsprocessor", "statsprocessor" },
    { "sucrack", "sucrack" },
    { "tftp-bruteforce", "tftp-bruteforce" },
    { "thc-pptp-bruter", "thc-pptp-bruter" },
    { "ufo-wardriving", "ufo-wardriving" },
    { "vnc-bypauth", "vnc-bypauth" },
    { "vncrack", "vncrack" },
    { "wifite", "wifite" },
    { "wmat", "wmat" },
    { "wyd", "wyd" },
    { "zulu", "zulu" },
}

cryptomenu = {
    { "bletchley", "bletchley" },
    { "ciphertest", "ciphertest" },
    { "hash-identifier", "hash-identifier" },
    { "nomorexor", "nomorexor" },
    { "sbd", "sbd" },
    { "xorbruteforcer", "xorbruteforcer" },
    { "xorsearch", "xorsearch" },
    { "xortool", "xortool" },
}

databasemenu = {
    { "blindsql", "blindsql" },
    { "getsids", "getsids" },
    { "metacoretex", "metacoretex" },
    { "minimysqlator", "minimysqlator" },
}

debuggermenu = {
    { "edb", "edb" },
    { "ollydbg", "ollydbg" },
    { "radare2", "radare2" },
    { "shellnoob", "shellnoob" },
    { "vivisect", "vivisect" },
}

decompilermenu = {
    { "flasm", "flasm" },
}

defensivemenu = {
    { "arpalert", "arpalert" },
    { "arpantispoofer", "arpantispoofer" },
    { "arpon", "arpon" },
    { "artillery", "artillery" },
    { "chkrootkit", "chkrootkit" },
    { "dbpwaudit", "dbpwaudit" },
    { "inetsim", "inetsim" },
    { "secure-delete", "secure-delete" },
    { "sniffjoke", "sniffjoke" },
    { "tor-autocircuit", "tor-autocircuit" },
}

disassemblermenu = {
    { "inguma", "inguma" },
    { "radare2", "radare2" },
    { "vivisect", "vivisect" },
}

dosmenu = {
    { "dnsdrdos", "dnsdrdos" },
    { "hwk", "hwk" },
    { "iaxflood", "iaxflood" },
    { "mausezahn", "mausezahn" },
    { "nkiller2", "nkiller2" },
    { "slowhttptest", "slowhttptest" },
    { "t50", "t50" },
    { "thc-ipv6", "thc-ipv6" },
    { "thc-ssl-dos", "thc-ssl-dos" },
}

dronemenu = {
    { "skyjack", "skyjack" },
}

exploitationmenu = {
    { "armitage", "armitage" },
    { "arpoison", "arpoison" },
    { "bbqsql", "bbqsql" },
    { "bed", "bed" },
    { "bfbtester", "bfbtester" },
    { "cisco-global-exploiter", "cisco-global-exploiter" },
    { "cisco-torch", "cisco-torch" },
    { "darkd0rk3r", "darkd0rk3r" },
    { "darkmysqli", "darkmysqli" },
    { "dotdotpwn", "dotdotpwn" },
    { "exploit-db", "exploit-db" },
    { "fimap", "fimap" },
    { "hamster", "hamster" },
    { "hcraft", "hcraft" },
    { "htexploit", "htexploit" },
    { "htshells", "htshells" },
    { "inguma", "inguma" },
    { "irpas", "irpas" },
    { "killerbee", "killerbee" },
    { "leroy-jenkins", "leroy-jenkins" },
    { "lfi-autopwn", "lfi-autopwn" },
    { "loki", "loki" },
    { "metasploit", "metasploit" },
    { "miranda-upnp", "miranda-upnp" },
    { "mitmap", "mitmap" },
    { "mitmproxy", "mitmproxy" },
    { "padbuster", "padbuster" },
    { "paxtest", "paxtest" },
    { "pblind", "pblind" },
    { "pentbox", "pentbox" },
    { "pirana", "pirana" },
    { "powersploit", "powersploit" },
    { "rebind", "rebind" },
    { "rfcat", "rfcat" },
    { "ropeme", "ropeme" },
    { "ropgadget", "ropgadget" },
    { "ruby-ronin-support", "ruby-ronin-support" },
    { "set", "set" },
    { "shellcodecs", "shellcodecs" },
    { "shellnoob", "shellnoob" },
    { "simple-ducky", "simple-ducky" },
    { "sipvicious", "sipvicious" },
    { "sploitctl", "sploitctl" },
    { "sqlmap", "sqlmap" },
    { "sqlninja", "sqlninja" },
    { "sqlsus", "sqlsus" },
    { "subterfuge", "subterfuge" },
    { "tcpjunk", "tcpjunk" },
    { "thc-ipv6", "thc-ipv6" },
    { "veil", "veil" },
    { "vnc-bypauth", "vnc-bypauth" },
    { "websploit", "websploit" },
    { "zarp", "zarp" },
}

fingerprintmenu = {
    { "asp-audit", "asp-audit" },
    { "blindelephant", "blindelephant" },
    { "cisco-torch", "cisco-torch" },
    { "cms-explorer", "cms-explorer" },
    { "complemento", "complemento" },
    { "dnsmap", "dnsmap" },
    { "ftpmap", "ftpmap" },
    { "httprint", "httprint" },
    { "kolkata", "kolkata" },
    { "p0f", "p0f" },
    { "plecost", "plecost" },
    { "propecia", "propecia" },
    { "sinfp", "sinfp" },
    { "smtpmap", "smtpmap" },
    { "smtpscan", "smtpscan" },
    { "xprobe2", "xprobe2" },
}

forensicmenu = {
    { "aesfix", "aesfix" },
    { "aeskeyfind", "aeskeyfind" },
    { "afflib", "afflib" },
    { "aimage", "aimage" },
    { "air", "air" },
    { "autopsy", "autopsy" },
    { "bios_memimage", "bios_memimage" },
    { "bulk-extractor", "bulk-extractor" },
    { "canari", "canari" },
    { "casefile", "casefile" },
    { "chkrootkit", "chkrootkit" },
    { "dc3dd", "dc3dd" },
    { "eindeutig", "eindeutig" },
    { "foremost", "foremost" },
    { "galleta", "galleta" },
    { "grokevt", "grokevt" },
    { "guymager", "guymager" },
    { "libewf", "libewf" },
    { "magicrescue", "magicrescue" },
    { "make-pdf", "make-pdf" },
    { "maltego", "maltego" },
    { "malwaredetect", "malwaredetect" },
    { "md5deep", "md5deep" },
    { "mdbtools", "mdbtools" },
    { "memdump", "memdump" },
    { "memfetch", "memfetch" },
    { "nfex", "nfex" },
    { "origami", "origami" },
    { "pasco", "pasco" },
    { "pdf-parser", "pdf-parser" },
    { "pdfid", "pdfid" },
    { "peepdf", "peepdf" },
    { "pev", "pev" },
    { "recoverjpeg", "recoverjpeg" },
    { "reglookup", "reglookup" },
    { "rifiuti2", "rifiuti2" },
    { "rsakeyfind", "rsakeyfind" },
    { "safecopy", "safecopy" },
    { "scalpel", "scalpel" },
    { "scrounge-ntfs", "scrounge-ntfs" },
    { "vinetto", "vinetto" },
    { "volatility", "volatility" },
    { "wyd", "wyd" },
}

fuzzermenu = {
    { "browser-fuzzer", "browser-fuzzer" },
    { "bss", "bss" },
    { "bt_audit", "bt_audit" },
    { "bunny", "bunny" },
    { "burpsuite", "burpsuite" },
    { "cirt-fuzzer", "cirt-fuzzer" },
    { "cisco-auditing-tool", "cisco-auditing-tool" },
    { "conscan", "conscan" },
    { "cookie-cadger", "cookie-cadger" },
    { "dotdotpwn", "dotdotpwn" },
    { "easyfuzzer", "easyfuzzer" },
    { "fimap", "fimap" },
    { "firewalk", "firewalk" },
    { "ftester", "ftester" },
    { "ftp-fuzz", "ftp-fuzz" },
    { "fusil", "fusil" },
    { "fuzzball2", "fuzzball2" },
    { "fuzzdb", "fuzzdb" },
    { "fuzzdiff", "fuzzdiff" },
    { "hexorbase", "hexorbase" },
    { "http-fuzz", "http-fuzz" },
    { "hwk", "hwk" },
    { "ikeprober", "ikeprober" },
    { "inguma", "inguma" },
    { "jbrofuzz", "jbrofuzz" },
    { "lfi-autopwn", "lfi-autopwn" },
    { "mdk3", "mdk3" },
    { "metasploit", "metasploit" },
    { "nikto", "nikto" },
    { "notspikefile", "notspikefile" },
    { "oat", "oat" },
    { "ohrwurm", "ohrwurm" },
    { "oscanner", "oscanner" },
    { "peach", "peach" },
    { "powerfuzzer", "powerfuzzer" },
    { "radamsa", "radamsa" },
    { "ratproxy", "ratproxy" },
    { "sfuzz", "sfuzz" },
    { "skipfish", "skipfish" },
    { "smtp-fuzz", "smtp-fuzz" },
    { "spiderpig-pdffuzzer", "spiderpig-pdffuzzer" },
    { "spike", "spike" },
    { "sqlbrute", "sqlbrute" },
    { "sqlmap", "sqlmap" },
    { "sqlninja", "sqlninja" },
    { "sulley", "sulley" },
    { "taof", "taof" },
    { "tcpcontrol-fuzzer", "tcpcontrol-fuzzer" },
    { "tcpjunk", "tcpjunk" },
    { "termineter", "termineter" },
    { "tftp-fuzz", "tftp-fuzz" },
    { "uniofuzz", "uniofuzz" },
    { "uniscan", "uniscan" },
    { "vulscan", "vulscan" },
    { "wapiti", "wapiti" },
    { "webscarab", "webscarab" },
    { "webshag", "webshag" },
    { "websploit", "websploit" },
    { "wfuzz", "wfuzz" },
    { "wsfuzzer", "wsfuzzer" },
    { "zaproxy", "zaproxy" },
    { "zzuf", "zzuf" },
}

hardwaremenu = {
    { "arduino", "arduino" },
    { "dex2jar", "dex2jar" },
    { "kautilya", "kautilya" },
    { "smali", "smali" },
}

honeypotmenu = {
    { "artillery", "artillery" },
    { "bluepot", "bluepot" },
    { "fakeap", "fakeap" },
    { "fiked", "fiked" },
    { "honeyd", "honeyd" },
    { "inetsim", "inetsim" },
    { "kippo", "kippo" },
    { "wifi-honey", "wifi-honey" },
}

malwaremenu = {
    { "malwaredetect", "malwaredetect" },
    { "peepdf", "peepdf" },
    { "python2-yara", "python2-yara" },
    { "yara", "yara" },
    { "zerowine", "zerowine" },
}

miscmenu = {
    { "3proxy", "3proxy" },
    { "airgraph-ng", "airgraph-ng" },
    { "binwalk", "binwalk" },
    { "bulk-extractor", "bulk-extractor" },
    { "cisco-router-config", "cisco-router-config" },
    { "cryptcat", "cryptcat" },
    { "dbd", "dbd" },
    { "dhcdrop", "dhcdrop" },
    { "elettra", "elettra" },
    { "elettra-gui", "elettra-gui" },
    { "ent", "ent" },
    { "evilgrade", "evilgrade" },
    { "fakemail", "fakemail" },
    { "firmware-mod-kit", "firmware-mod-kit" },
    { "flare", "flare" },
    { "genlist", "genlist" },
    { "geoedge", "geoedge" },
    { "geoipgen", "geoipgen" },
    { "hackersh", "hackersh" },
    { "http-put", "http-put" },
    { "inundator", "inundator" },
    { "laudanum", "laudanum" },
    { "leo", "leo" },
    { "list-urls", "list-urls" },
    { "mibble", "mibble" },
    { "netactview", "netactview" },
    { "oh-my-zsh-git", "oh-my-zsh-git" },
    { "perl-tftp", "perl-tftp" },
    { "pyinstaller", "pyinstaller" },
    { "python-utidylib", "python-utidylib" },
    { "sakis3g", "sakis3g" },
    { "schnappi-dhcp", "schnappi-dhcp" },
    { "sslcat", "sslcat" },
    { "sslyze", "sslyze" },
    { "stompy", "stompy" },
    { "tcpxtract", "tcpxtract" },
    { "tnscmd", "tnscmd" },
    { "tpcat", "tpcat" },
    { "uatester", "uatester" },
    { "vfeed", "vfeed" },
    { "wol-e", "wol-e" },
}

mobilemenu = {
    { "android-udev-rules", "android-udev-rules" },
}

networkingmenu = {
    { "httping", "httping" },
    { "hyenae", "hyenae" },
    { "ipaudit", "ipaudit" },
    { "jnetmap", "jnetmap" },
    { "mausezahn", "mausezahn" },
    { "middler", "middler" },
    { "nbtool", "nbtool" },
    { "netmap", "netmap" },
    { "netsed", "netsed" },
    { "nfex", "nfex" },
    { "nfsshell", "nfsshell" },
    { "nipper", "nipper" },
    { "nkiller2", "nkiller2" },
    { "packit", "packit" },
    { "perl-tftp", "perl-tftp" },
    { "ptunnel", "ptunnel" },
    { "pwnat", "pwnat" },
    { "pyminifakedns", "pyminifakedns" },
    { "responder", "responder" },
    { "rtpbreak", "rtpbreak" },
    { "sbd", "sbd" },
    { "scapy", "scapy" },
    { "snmpcheck", "snmpcheck" },
    { "sslstrip", "sslstrip" },
    { "t50", "t50" },
    { "tcptraceroute", "tcptraceroute" },
    { "thc-ipv6", "thc-ipv6" },
    { "udptunnel", "udptunnel" },
    { "wol-e", "wol-e" },
    { "yersinia", "yersinia" },
    { "zarp", "zarp" },
}

nfcmenu = {
    { "nfcutils", "nfcutils" },
}

packermenu = {
    { "packerid", "packerid" },
}

proxymenu = {
    { "burpsuite", "burpsuite" },
    { "dnschef", "dnschef" },
    { "fakedns", "fakedns" },
    { "mitmproxy", "mitmproxy" },
    { "pathod", "pathod" },
    { "ratproxy", "ratproxy" },
    { "sergio-proxy", "sergio-proxy" },
    { "sslnuke", "sslnuke" },
    { "webscarab", "webscarab" },
}

reconmenu = {
    { "canari", "canari" },
    { "casefile", "casefile" },
    { "cutycapt", "cutycapt" },
    { "dnsenum", "dnsenum" },
    { "dnsrecon", "dnsrecon" },
    { "dnsspider", "dnsspider" },
    { "dnswalk", "dnswalk" },
    { "enum4linux", "enum4linux" },
    { "goodork", "goodork" },
    { "goofile", "goofile" },
    { "goog-mail", "goog-mail" },
    { "gwtenum", "gwtenum" },
    { "halcyon", "halcyon" },
    { "httping", "httping" },
    { "intrace", "intrace" },
    { "isr-form", "isr-form" },
    { "lbd", "lbd" },
    { "ldapenum", "ldapenum" },
    { "lft", "lft" },
    { "linux-exploit-suggester", "linux-exploit-suggester" },
    { "maltego", "maltego" },
    { "metagoofil", "metagoofil" },
    { "missidentify", "missidentify" },
    { "nbtool", "nbtool" },
    { "netdiscover", "netdiscover" },
    { "netmask", "netmask" },
    { "nipper", "nipper" },
    { "nsec3walker", "nsec3walker" },
    { "pastenum", "pastenum" },
    { "recon-ng", "recon-ng" },
    { "rifiuti2", "rifiuti2" },
    { "ripdc", "ripdc" },
    { "sctpscan", "sctpscan" },
    { "smtp-user-enum", "smtp-user-enum" },
    { "snmpcheck", "snmpcheck" },
    { "spiderfoot", "spiderfoot" },
    { "subdomainer", "subdomainer" },
    { "theharvester", "theharvester" },
    { "twofi", "twofi" },
    { "whatweb", "whatweb" },
}

reversingmenu = {
    { "capstone", "capstone" },
    { "dex2jar", "dex2jar" },
    { "edb", "edb" },
    { "flasm", "flasm" },
    { "javasnoop", "javasnoop" },
    { "jd-gui", "jd-gui" },
    { "js-beautify", "js-beautify" },
    { "packerid", "packerid" },
    { "pev", "pev" },
    { "radare2", "radare2" },
    { "recstudio", "recstudio" },
    { "scanmem", "scanmem" },
    { "swfintruder", "swfintruder" },
    { "udis86", "udis86" },
    { "vivisect", "vivisect" },
    { "zerowine", "zerowine" },
}

scannermenu = {
    { "admsnmp", "admsnmp" },
    { "allthevhosts", "allthevhosts" },
    { "asp-audit", "asp-audit" },
    { "bluelog", "bluelog" },
    { "braa", "braa" },
    { "bss", "bss" },
    { "btscanner", "btscanner" },
    { "burpsuite", "burpsuite" },
    { "canari", "canari" },
    { "casefile", "casefile" },
    { "checksec", "checksec" },
    { "cisco-auditing-tool", "cisco-auditing-tool" },
    { "cisco-torch", "cisco-torch" },
    { "ciscos", "ciscos" },
    { "complemento", "complemento" },
    { "conscan", "conscan" },
    { "cookie-cadger", "cookie-cadger" },
    { "creepy", "creepy" },
    { "davtest", "davtest" },
    { "deblaze", "deblaze" },
    { "dhcpig", "dhcpig" },
    { "dirb", "dirb" },
    { "dirbuster", "dirbuster" },
    { "dmitry", "dmitry" },
    { "dnmap", "dnmap" },
    { "dnsa", "dnsa" },
    { "dnsbf", "dnsbf" },
    { "dnsenum", "dnsenum" },
    { "dnsgoblin", "dnsgoblin" },
    { "dnspredict", "dnspredict" },
    { "dnsspider", "dnsspider" },
    { "dnswalk", "dnswalk" },
    { "dpscan", "dpscan" },
    { "driftnet", "driftnet" },
    { "dripper", "dripper" },
    { "enum4linux", "enum4linux" },
    { "enumiax", "enumiax" },
    { "fierce", "fierce" },
    { "firewalk", "firewalk" },
    { "flawfinder", "flawfinder" },
    { "ftpmap", "ftpmap" },
    { "ghost-phisher", "ghost-phisher" },
    { "grepforrfi", "grepforrfi" },
    { "gsa", "gsa" },
    { "gsd", "gsd" },
    { "halberd", "halberd" },
    { "hexorbase", "hexorbase" },
    { "http-enum", "http-enum" },
    { "hwk", "hwk" },
    { "icmpquery", "icmpquery" },
    { "ike-scan", "ike-scan" },
    { "inguma", "inguma" },
    { "ipscan", "ipscan" },
    { "jigsaw", "jigsaw" },
    { "jsql", "jsql" },
    { "ldapenum", "ldapenum" },
    { "lynis", "lynis" },
    { "maltego", "maltego" },
    { "masscan", "masscan" },
    { "metasploit", "metasploit" },
    { "miranda-upnp", "miranda-upnp" },
    { "mssqlscan", "mssqlscan" },
    { "nbtool", "nbtool" },
    { "nikto", "nikto" },
    { "nmbscan", "nmbscan" },
    { "onesixtyone", "onesixtyone" },
    { "openvas-administrator", "openvas-administrator" },
    { "openvas-cli", "openvas-cli" },
    { "openvas-client", "openvas-client" },
    { "openvas-manager", "openvas-manager" },
    { "openvas-scanner", "openvas-scanner" },
    { "paketto", "paketto" },
    { "pnscan", "pnscan" },
    { "propecia", "propecia" },
    { "ratproxy", "ratproxy" },
    { "rawr", "rawr" },
    { "redfang", "redfang" },
    { "relay-scanner", "relay-scanner" },
    { "ripdc", "ripdc" },
    { "scanssh", "scanssh" },
    { "sctpscan", "sctpscan" },
    { "skipfish", "skipfish" },
    { "smtp-user-enum", "smtp-user-enum" },
    { "smtp-vrfy", "smtp-vrfy" },
    { "snmpenum", "snmpenum" },
    { "snmpscan", "snmpscan" },
    { "sslcaudit", "sslcaudit" },
    { "sslscan", "sslscan" },
    { "subdomainer", "subdomainer" },
    { "synscan", "synscan" },
    { "tiger", "tiger" },
    { "tlssled", "tlssled" },
    { "unicornscan", "unicornscan" },
    { "uniscan", "uniscan" },
    { "unix-privesc-check", "unix-privesc-check" },
    { "upnpscan", "upnpscan" },
    { "videosnarf", "videosnarf" },
    { "vulscan", "vulscan" },
    { "waffit", "waffit" },
    { "wapiti", "wapiti" },
    { "webenum", "webenum" },
    { "webrute", "webrute" },
    { "webscarab", "webscarab" },
    { "webshag", "webshag" },
    { "websploit", "websploit" },
    { "wnmap", "wnmap" },
    { "wpscan", "wpscan" },
    { "yersinia", "yersinia" },
    { "zmap", "zmap" },
}

sniffermenu = {
    { "cdpsnarf", "cdpsnarf" },
    { "driftnet", "driftnet" },
    { "hexinject", "hexinject" },
    { "mitmap", "mitmap" },
    { "netsniff-ng", "netsniff-ng" },
    { "p0f", "p0f" },
    { "passivedns", "passivedns" },
    { "phoss", "phoss" },
    { "pytacle", "pytacle" },
    { "ssldump", "ssldump" },
    { "sslsniff", "sslsniff" },
    { "tcpick", "tcpick" },
    { "tuxcut", "tuxcut" },
    { "wifi-monitor", "wifi-monitor" },
    { "xspy", "xspy" },
}

socialmenu = {
    { "creepy", "creepy" },
    { "jigsaw", "jigsaw" },
    { "set", "set" },
    { "websploit", "websploit" },
}

spoofmenu = {
    { "admid-pack", "admid-pack" },
    { "arpoison", "arpoison" },
    { "fakedns", "fakedns" },
    { "inundator", "inundator" },
    { "lans", "lans" },
    { "lsrtunnel", "lsrtunnel" },
    { "multimac", "multimac" },
    { "nbnspoof", "nbnspoof" },
    { "netcommander", "netcommander" },
    { "pyminifakedns", "pyminifakedns" },
    { "sergio-proxy", "sergio-proxy" },
}

threatmodelmenu = {
    { "magictree", "magictree" },
}

tunnelmenu = {
    { "chownat", "chownat" },
    { "ctunnel", "ctunnel" },
    { "dns2tcp", "dns2tcp" },
    { "icmptx", "icmptx" },
    { "iodine", "iodine" },
    { "matahari", "matahari" },
    { "ptunnel", "ptunnel" },
    { "udptunnel", "udptunnel" },
}

unpackermenu = {
    { "js-beautify", "js-beautify" },
}

voipmenu = {
    { "ace", "ace" },
    { "erase-registrations", "erase-registrations" },
    { "iaxflood", "iaxflood" },
    { "pcapsipdump", "pcapsipdump" },
    { "redirectpoison", "redirectpoison" },
    { "rtp-flood", "rtp-flood" },
    { "siparmyknife", "siparmyknife" },
    { "sipcrack", "sipcrack" },
    { "sipp", "sipp" },
    { "sipsak", "sipsak" },
    { "teardown", "teardown" },
    { "vnak", "vnak" },
    { "voiper", "voiper" },
    { "voiphopper", "voiphopper" },
    { "voipong", "voipong" },
}

webappmenu = {
    { "allthevhosts", "allthevhosts" },
    { "asp-audit", "asp-audit" },
    { "bbqsql", "bbqsql" },
    { "blindelephant", "blindelephant" },
    { "bsqlbf", "bsqlbf" },
    { "burpsuite", "burpsuite" },
    { "cms-explorer", "cms-explorer" },
    { "csrftester", "csrftester" },
    { "darkd0rk3r", "darkd0rk3r" },
    { "darkjumper", "darkjumper" },
    { "darkmysqli", "darkmysqli" },
    { "dff-scanner", "dff-scanner" },
    { "dirb", "dirb" },
    { "dirbuster", "dirbuster" },
    { "easyfuzzer", "easyfuzzer" },
    { "golismero", "golismero" },
    { "grabber", "grabber" },
    { "gwtenum", "gwtenum" },
    { "halberd", "halberd" },
    { "isr-form", "isr-form" },
    { "joomscan", "joomscan" },
    { "kolkata", "kolkata" },
    { "laudanum", "laudanum" },
    { "list-urls", "list-urls" },
    { "metoscan", "metoscan" },
    { "multiinjector", "multiinjector" },
    { "nikto", "nikto" },
    { "owtf", "owtf" },
    { "paros", "paros" },
    { "pblind", "pblind" },
    { "plecost", "plecost" },
    { "ratproxy", "ratproxy" },
    { "rawr", "rawr" },
    { "rww-attack", "rww-attack" },
    { "skipfish", "skipfish" },
    { "spike-proxy", "spike-proxy" },
    { "sqid", "sqid" },
    { "sqlbrute", "sqlbrute" },
    { "sqlmap", "sqlmap" },
    { "sqlninja", "sqlninja" },
    { "sqlsus", "sqlsus" },
    { "uatester", "uatester" },
    { "uniscan", "uniscan" },
    { "urlcrazy", "urlcrazy" },
    { "vega", "vega" },
    { "waffit", "waffit" },
    { "wapiti", "wapiti" },
    { "webacoo", "webacoo" },
    { "webenum", "webenum" },
    { "webhandler", "webhandler" },
    { "webrute", "webrute" },
    { "webscarab", "webscarab" },
    { "webshag", "webshag" },
    { "webshells", "webshells" },
    { "webslayer", "webslayer" },
    { "weevely", "weevely" },
    { "wfuzz", "wfuzz" },
    { "whatweb", "whatweb" },
    { "wmat", "wmat" },
    { "wpscan", "wpscan" },
    { "wsfuzzer", "wsfuzzer" },
    { "xsser", "xsser" },
    { "xsss", "xsss" },
    { "zaproxy", "zaproxy" },
}

windowsmenu = {
    { "3proxy-win32", "3proxy-win32" },
    { "brutus", "brutus" },
    { "creddump", "creddump" },
    { "dumpacl", "dumpacl" },
    { "fport", "fport" },
    { "handle", "handle" },
    { "httprint-win32", "httprint-win32" },
    { "hyperion", "hyperion" },
    { "ikeprobe", "ikeprobe" },
    { "klogger", "klogger" },
    { "mbenum", "mbenum" },
    { "missidentify", "missidentify" },
    { "nbtenum", "nbtenum" },
    { "nishang", "nishang" },
    { "ollydbg", "ollydbg" },
    { "orakelcrackert", "orakelcrackert" },
    { "powersploit", "powersploit" },
    { "pstoreview", "pstoreview" },
    { "pwdump", "pwdump" },
    { "sipscan", "sipscan" },
    { "smbrelay", "smbrelay" },
    { "snscan", "snscan" },
    { "spade", "spade" },
    { "sqlping", "sqlping" },
    { "superscan", "superscan" },
    { "sysinternals-suite", "sysinternals-suite" },
    { "unsecure", "unsecure" },
    { "winfo", "winfo" },
    { "x-scan", "x-scan" },
}

wirelessmenu = {
    { "airflood", "airflood" },
    { "airoscript", "airoscript" },
    { "airpwn", "airpwn" },
    { "batctl", "batctl" },
    { "batman-adv", "batman-adv" },
    { "bully", "bully" },
    { "cowpatty", "cowpatty" },
    { "eapmd5pass", "eapmd5pass" },
    { "fern-wifi-cracker", "fern-wifi-cracker" },
    { "g72x++", "g72x++" },
    { "giskismet", "giskismet" },
    { "gqrx", "gqrx" },
    { "hotspotter", "hotspotter" },
    { "hwk", "hwk" },
    { "killerbee", "killerbee" },
    { "kismet-earth", "kismet-earth" },
    { "mdk3", "mdk3" },
    { "mfcuk", "mfcuk" },
    { "mfoc", "mfoc" },
    { "netdiscover", "netdiscover" },
    { "pyrit", "pyrit" },
    { "rfdump", "rfdump" },
    { "rfidiot", "rfidiot" },
    { "rfidtool", "rfidtool" },
    { "spectools", "spectools" },
    { "ufo-wardriving", "ufo-wardriving" },
    { "wepbuster", "wepbuster" },
    { "wiffy", "wiffy" },
    { "wifi-honey", "wifi-honey" },
    { "wifitap", "wifitap" },
    { "wifite", "wifite" },
    { "wlan2eth", "wlan2eth" },
    { "zulu", "zulu" },
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
