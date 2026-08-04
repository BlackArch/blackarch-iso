#!/usr/bin/env python3
"""Shared logic for generating XDG menu entries from installed BlackArch tools.

Queries pacman for which BlackArch packages are actually installed, works out a
launchable command for each one, and emits the three kinds of file the XDG menu
spec needs:

  * ``.desktop``   one per installed tool, tagged with ``X-BlackArch-<group>``
  * ``.directory``  one per BlackArch group, plus one for the root menu
  * ``.menu``       the XML fragment that nests the group menus under "BlackArch"

Both ``BlackArchPlasmaMenuTool.py`` (Plasma) and ``BlackArchCinnamonMenu.py`` (Cinnamon)
are thin front-ends over this module; the generated files are identical, only the
merge directories and the cache-refresh commands differ.
"""

from __future__ import annotations

import os
import pwd
import re
import shutil
import subprocess
import sys
import xml.etree.ElementTree as ElementTree
from dataclasses import dataclass, field
from pathlib import Path
from xml.sax.saxutils import escape as xml_escape

# The "blackarch" group holds every tool in the repo, so it would duplicate the
# whole tree into one giant submenu. The groups we care about are the topical ones.
META_GROUP = "blackarch"
GROUP_PREFIX = "blackarch-"

# Group names whose title-cased form reads wrong.
PRETTY_OVERRIDES = {
    "ai": "AI",
    "dos": "DoS",
    "gpu": "GPU",
    "ids": "IDS",
    "nfc": "NFC",
    "voip": "VoIP",
    "webapp": "Web Apps",
    "code-audit": "Code Audit",
    "anti-forensic": "Anti Forensic",
    "threat-model": "Threat Model",
    "reocn": "Reocn",  # upstream typo of "recon", kept so the group still shows
}

# Icon names from the freedesktop icon-naming spec / Breeze. A missing name just
# falls back to a generic icon in the launcher, so these are safe guesses.
GROUP_ICONS = {
    "ai": "applications-science",
    "anti-forensic": "edit-delete",
    "automation": "system-run",
    "automobile": "applications-other",
    "backdoor": "applications-system",
    "binary": "application-x-executable",
    "bluetooth": "preferences-system-bluetooth",
    "code-audit": "text-x-script",
    "config": "preferences-system",
    "cracker": "dialog-password",
    "crypto": "security-high",
    "database": "server-database",
    "debugger": "applications-development",
    "decompiler": "applications-development",
    "defensive": "security-high",
    "disassembler": "applications-development",
    "dos": "network-offline",
    "drone": "applications-other",
    "exploitation": "applications-system",
    "fingerprint": "system-search",
    "firmware": "application-x-firmware",
    "forensic": "system-search",
    "fuzzer": "applications-development",
    "gpu": "video-display",
    "hardware": "computer",
    "honeypot": "network-server",
    "ids": "security-medium",
    "keylogger": "input-keyboard",
    "malware": "security-low",
    "misc": "applications-other",
    "mobile": "phone",
    "networking": "network-wired",
    "nfc": "media-flash",
    "packer": "package-x-generic",
    "proxy": "preferences-system-network",
    "radio": "network-wireless",
    "recon": "system-search",
    "reocn": "system-search",
    "reversing": "applications-development",
    "scanner": "system-search",
    "sniffer": "utilities-system-monitor",
    "social": "system-users",
    "spoof": "user-identity",
    "stego": "image-x-generic",
    "threat-model": "applications-office",
    "tunnel": "network-vpn",
    "unpacker": "package-x-generic",
    "voip": "call-start",
    "webapp": "applications-internet",
    "windows": "applications-other",
    "wireless": "network-wireless",
    "wordlist": "text-x-generic",
}
ROOT_ICON = "security-high"
FALLBACK_ICON = "utilities-terminal"

# Stripped before matching a package name against the binaries it ships, so
# "python2-ldapdomaindump" can still find /usr/bin/ldapdomaindump.
NAME_PREFIXES = ("python-", "python2-", "python3-", "perl-", "ruby-", "go-", "lib")
NAME_SUFFIXES = ("-git", "-svn", "-hg", "-bzr", "-bin", "-cvs", "-dkms-git", "-dkms")

ICON_EXTENSIONS = (".png", ".svg", ".svgz", ".xpm")

# Directories that hold metadata rather than a runnable payload, so a package that
# only owns one of these (a kernel module shipping /usr/share/doc/<pkg>/) is not
# mistaken for a data-only tool.
NON_PAYLOAD_DIRS = (
    "/usr/share/doc/",
    "/usr/share/licenses/",
    "/usr/share/man/",
    "/usr/share/info/",
    "/usr/share/locale/",
    "/usr/share/applications/",
    "/usr/share/icons/",
    "/usr/share/pixmaps/",
    "/usr/share/metainfo/",
    "/usr/share/appdata/",
    "/usr/share/bash-completion/",
    "/usr/share/zsh/",
)

# Packages whose main command cannot be derived from the package name. The upstream
# stub called this the "exception list"; it only needs entries the heuristic in
# pick_binary() gets wrong.
COMMAND_OVERRIDES = {
    "radare2-cutter": "cutter",
    "hwk": "hawk",
    "zaproxy": "zap",
    "beef": "beef-xss",
    "thc-ipv6": "atk6-alive6",
    "social-engineer-toolkit": "setoolkit",
}

# A CLI tool's entry is just the bare command, so a menu editor shows the binary
# as the program with no arguments attached. Data-only packages have no command of
# their own, so theirs opens the package directory in the file manager instead.
BROWSE_COMMAND = "xdg-open"

# The form the system's own menu files use, so every file we write or rewrite
# carries an identical doctype.
MENU_DOCTYPE = (
    '<!DOCTYPE Menu PUBLIC "-//freedesktop//DTD Menu 1.0//EN"\n'
    ' "http://www.freedesktop.org/standards/menu-spec/1.0/menu.dtd">\n'
)
MENU_HEADER = MENU_DOCTYPE + (
    "<!-- Generated by BlackArchPlasmaMenuTool. Do not edit;"
    " rerun the generator instead. -->\n"
)


class PacmanError(RuntimeError):
    """Raised when pacman is missing or a query fails."""


@dataclass
class Tool:
    """One installed BlackArch package, resolved to something launchable."""

    package: str
    description: str
    groups: list[str]
    exec_command: list[str] = field(default_factory=list)
    icon: str = ""
    terminal: bool = True
    display_name: str = ""

    @property
    def launchable(self) -> bool:
        return bool(self.exec_command)


# --------------------------------------------------------------------------- #
# pacman queries
# --------------------------------------------------------------------------- #


def _run_pacman(args: list[str]) -> subprocess.CompletedProcess[str]:
    if shutil.which("pacman") is None:
        raise PacmanError("pacman not found -- this tool only runs on Arch/BlackArch.")
    return subprocess.run(
        ["pacman", *args],
        capture_output=True,
        text=True,
        check=False,
        # `pacman -Qi` translates its field labels, so a German system reports
        # "Gruppen" and _parse_query_info() below finds nothing. Pin the child's
        # locale rather than teaching the parser every language.
        env={**os.environ, "LC_ALL": "C"},
    )


def _pacman(args: list[str]) -> str:
    result = _run_pacman(args)
    if result.returncode != 0:
        raise PacmanError(
            f"`pacman {' '.join(args)}` failed ({result.returncode}): "
            f"{result.stderr.strip()}"
        )
    return result.stdout


def installed_packages() -> list[str]:
    """Every installed member of the umbrella `blackarch` group.

    A group with no installed members does not exist as far as `pacman -Qg` is
    concerned, so it reports "not found" and exits non-zero; that is an empty
    result, not a failure. Anything else -- a locked or corrupt database, or no
    pacman at all -- is real and propagates to the caller.
    """
    result = _run_pacman(["-Qgq", META_GROUP])
    if result.returncode != 0:
        if "was not found" in result.stderr:
            return []
        raise PacmanError(
            f"`pacman -Qgq {META_GROUP}` failed ({result.returncode}): "
            f"{result.stderr.strip()}"
        )
    return sorted({line.strip() for line in result.stdout.splitlines() if line.strip()})


def _parse_query_info(text: str) -> dict[str, dict[str, str]]:
    """Parse `pacman -Qi` output into {package: {field: value}}."""
    packages: dict[str, dict[str, str]] = {}
    current: dict[str, str] = {}
    last_key = ""
    for line in text.splitlines():
        if not line.strip():
            if current.get("Name"):
                packages[current["Name"]] = current
            current, last_key = {}, ""
            continue
        if line[0].isspace() and last_key:
            # Continuation of a wrapped field.
            current[last_key] = f"{current[last_key]} {line.strip()}"
            continue
        key, sep, value = line.partition(":")
        if not sep:
            continue
        last_key = key.strip()
        current[last_key] = value.strip()
    if current.get("Name"):
        packages[current["Name"]] = current
    return packages


def query_metadata(packages: list[str]) -> dict[str, dict[str, str]]:
    if not packages:
        return {}
    return _parse_query_info(_pacman(["-Qi", *packages]))


def query_file_lists(packages: list[str]) -> dict[str, list[str]]:
    """{package: [owned paths]} from a single `pacman -Ql` call."""
    if not packages:
        return {}
    files: dict[str, list[str]] = {pkg: [] for pkg in packages}
    for line in _pacman(["-Ql", *packages]).splitlines():
        pkg, _, path = line.partition(" ")
        if pkg in files:
            files[pkg].append(path.strip())
    return files


# --------------------------------------------------------------------------- #
# resolving a package to a launchable command
# --------------------------------------------------------------------------- #


def normalise(name: str) -> str:
    """Strip packaging noise so a package name can be matched against a binary."""
    for suffix in NAME_SUFFIXES:
        if name.endswith(suffix) and len(name) > len(suffix):
            name = name[: -len(suffix)]
    for prefix in NAME_PREFIXES:
        if name.startswith(prefix) and len(name) > len(prefix):
            name = name[len(prefix) :]
            break
    return name


def pick_binary(package: str, binaries: list[str]) -> str:
    """Choose the binary that best represents `package`.

    Packages such as `rfidiot` ship 35 executables; listing them all would bury
    the menu, so each package gets exactly one entry pointing at its main tool.
    """
    if not binaries:
        return ""
    override = COMMAND_OVERRIDES.get(package)
    if override in binaries:
        return override
    if package in binaries:
        return package
    target = normalise(package)
    if target in binaries:
        return target
    if len(binaries) == 1:
        return binaries[0]

    def score(binary: str) -> tuple[int, int, str]:
        base = normalise(binary)
        if base == target:
            rank = 0
        elif binary.startswith(target) or target.startswith(binary):
            rank = 1
        elif target in binary or binary in target:
            rank = 2
        else:
            rank = 3
        # Shorter names are usually the entry point (`mana` over `mana-carrier`).
        return (rank, len(binary), binary)

    return min(binaries, key=score)


def find_icon(package: str, paths: list[str]) -> str:
    """An icon name (themed) or absolute path shipped by the package, if any."""
    themed: list[tuple[int, str]] = []
    pixmaps: list[tuple[int, str]] = []
    target = normalise(package)
    for path in paths:
        if not path.endswith(ICON_EXTENSIONS):
            continue
        stem = Path(path).stem
        # Prefer an icon actually named after the package.
        affinity = 0 if stem in (package, target) else 1
        if "/icons/hicolor/" in path and "/apps/" in path:
            themed.append((affinity, stem))
        elif "/pixmaps/" in path:
            pixmaps.append((affinity, "/" + path.lstrip("/")))
    for candidates in (themed, pixmaps):
        if candidates:
            return min(candidates)[1]
    return ""


def find_data_dir(package: str, paths: list[str]) -> Path | None:
    """A directory named after the package holding its payload, if it has one.

    BlackArch ships a fair number of packages with nothing in /usr/bin: Windows
    executables land in /usr/share/windows/<pkg>/, wordlists and firmware images
    in /usr/share/<pkg>/, larger SDKs in /opt/<pkg>/.
    """
    candidates = []
    for path in paths:
        absolute = "/" + path.lstrip("/")
        if not absolute.endswith("/"):
            continue
        if not absolute.startswith(("/usr/share/", "/opt/")):
            continue
        if absolute.startswith(NON_PAYLOAD_DIRS):
            continue  # /usr/share/doc/<pkg>/ is not a tool
        if Path(absolute.rstrip("/")).name == package:
            candidates.append(absolute.rstrip("/"))
    if not candidates:
        return None
    # Shallowest match wins, so /usr/share/foo beats /usr/share/foo/data/foo.
    return Path(min(candidates, key=lambda p: (p.count("/"), p)))


def sanitise_icon(icon: str) -> str:
    """Icon names must not carry a file extension; absolute paths may.

    Some packages ship a .desktop file with `Icon=loic.png`, which the icon theme
    spec forbids and desktop-file-validate rejects, so mirroring it verbatim would
    propagate the bug into our entry.
    """
    if not icon or icon.startswith("/"):
        return icon
    stem, dot, extension = icon.rpartition(".")
    if dot and f".{extension.lower()}" in ICON_EXTENSIONS:
        return stem
    return icon


def parse_desktop_entry(path: Path) -> dict[str, str]:
    """Read the `[Desktop Entry]` group of an existing .desktop file."""
    entry: dict[str, str] = {}
    in_group = False
    try:
        text = path.read_text(encoding="utf-8", errors="replace")
    except OSError:
        return entry
    for line in text.splitlines():
        line = line.strip()
        if line.startswith("["):
            in_group = line == "[Desktop Entry]"
            continue
        if not in_group or not line or line.startswith("#"):
            continue
        key, sep, value = line.partition("=")
        if sep and "[" not in key:  # skip localised keys like Name[de]
            entry[key.strip()] = value.strip()
    return entry


def find_upstream_entry(package: str, paths: list[str]) -> dict[str, str]:
    """The package's own `[Desktop Entry]`, if it ships one worth mirroring.

    Upstream knows the right arguments, icon and whether the app wants a
    terminal, so mirroring beats guessing. Entries the packager deliberately hid
    are left hidden, and non-application entries (link and directory stubs) have
    nothing launchable to mirror.
    """
    candidates = [
        Path("/" + path.lstrip("/"))
        for path in paths
        if path.endswith(".desktop") and "/share/applications/" in "/" + path.lstrip("/")
    ]
    # A package shipping several entries (a suite plus its helpers) gets the one
    # named after the package; ties fall back to a stable alphabetical order.
    target = normalise(package)
    candidates.sort(key=lambda p: (p.stem not in (package, target), str(p)))
    for path in candidates:
        entry = parse_desktop_entry(path)
        if not entry.get("Exec"):
            continue
        if entry.get("Type", "Application") != "Application":
            continue
        if any(
            entry.get(key, "").strip().lower() == "true"
            for key in ("NoDisplay", "Hidden")
        ):
            continue
        return entry
    return {}


def build_tool(package: str, info: dict[str, str], paths: list[str]) -> Tool:
    groups = [
        g[len(GROUP_PREFIX) :]
        for g in info.get("Groups", "").split()
        if g.startswith(GROUP_PREFIX)
    ]
    tool = Tool(
        package=package,
        description=info.get("Description", "").rstrip("."),
        groups=sorted(set(groups)),
        display_name=package,
    )

    entry = find_upstream_entry(package, paths)
    if entry:
        tool.exec_command = ["@raw", entry["Exec"]]
        tool.icon = entry.get("Icon", "")
        tool.terminal = entry.get("Terminal", "false").strip().lower() == "true"
        tool.display_name = entry.get("Name", package)
        if entry.get("Comment"):
            tool.description = entry["Comment"]
    else:
        binaries = sorted(
            Path(p).name
            for p in paths
            if re.fullmatch(r"/usr/bin/[^/]+", "/" + p.lstrip("/"))
        )
        binary = pick_binary(package, binaries)
        data_dir = None if binary else find_data_dir(package, paths)
        if binary:
            tool.exec_command = ["@run", binary]
            tool.terminal = True
        elif data_dir:
            # Data-only packages (Windows executables under /usr/share/windows,
            # wordlists, firmware images) still belong in the menu -- their entry
            # opens the package directory in the file manager instead.
            tool.exec_command = ["@browse", str(data_dir)]
            tool.terminal = False

    if not tool.icon:
        tool.icon = find_icon(package, paths)
    tool.icon = sanitise_icon(tool.icon)
    return tool


def collect_tools() -> tuple[list[Tool], list[str]]:
    """All installed BlackArch tools, plus the names of any we could not launch."""
    packages = installed_packages()
    if not packages:
        return [], []
    metadata = query_metadata(packages)
    file_lists = query_file_lists(packages)

    tools, skipped = [], []
    for package in packages:
        tool = build_tool(package, metadata.get(package, {}), file_lists.get(package, []))
        # No groups means it is only in the umbrella group, so there is nowhere to
        # file it; not launchable means there is nothing to put in the entry.
        if tool.groups and tool.launchable:
            tools.append(tool)
        else:
            skipped.append(package)
    return tools, sorted(skipped)


# --------------------------------------------------------------------------- #
# file generation
# --------------------------------------------------------------------------- #


def pretty_group(group: str) -> str:
    if group in PRETTY_OVERRIDES:
        return PRETTY_OVERRIDES[group]
    return " ".join(word.capitalize() for word in group.replace("_", "-").split("-"))


def group_label(group: str, nested: bool = False) -> str:
    """The title a group's menu shows in the launcher.

    Flat group menus sit beside Development, Games and System, so they carry the
    "BlackArch" prefix themselves -- otherwise entries like "Misc" and "Windows"
    would be indistinguishable from the stock categories. Nested ones inherit the
    prefix from their parent menu.
    """
    return pretty_group(group) if nested else f"BlackArch {pretty_group(group)}"


def category_for(group: str) -> str:
    return f"X-BlackArch-{group}"


def escape_value(value: str) -> str:
    """Escape a desktop-entry value (spec section 'Value types')."""
    return (
        value.replace("\\", "\\\\")
        .replace("\n", " ")
        .replace("\r", " ")
        .replace("\t", " ")
        .strip()
    )


def quote_exec_arg(arg: str) -> str:
    """Quote one Exec argument per the desktop-entry spec."""
    if re.fullmatch(r"[A-Za-z0-9_@%+=:,./-]+", arg):
        return arg.replace("%", "%%")
    escaped = arg.replace("\\", "\\\\").replace('"', '\\"').replace("%", "%%")
    return f'"{escaped}"'


@dataclass
class Layout:
    """Where generated files go."""

    applications: Path
    directories: Path
    legacy_helpers: Path
    merge_dirs: list[Path]
    system_wide: bool = False

    @classmethod
    def user(cls, merge_dir_names: list[str], session: "Session") -> "Layout":
        # Routed through Session so that `sudo` without --system still targets the
        # desktop user's home: under sudo, HOME and XDG_* describe root, and
        # installing there would be a silent no-op for the person at the screen.
        return cls(
            applications=session.data / "applications" / "blackarch",
            directories=session.data / "desktop-directories",
            legacy_helpers=session.data / "blackarch-menu",
            merge_dirs=[session.config / "menus" / name for name in merge_dir_names],
        )

    @classmethod
    def system(cls, merge_dir_names: list[str]) -> "Layout":
        return cls(
            applications=Path("/usr/share/applications/blackarch"),
            directories=Path("/usr/share/desktop-directories"),
            legacy_helpers=Path("/usr/share/blackarch-menu"),
            merge_dirs=[Path("/etc/xdg/menus") / name for name in merge_dir_names],
            system_wide=True,
        )


class Generator:
    """Writes (or removes) the desktop/directory/menu files for a set of tools."""

    MENU_FILENAME = "blackarch.menu"
    ROOT_DIRECTORY = "blackarch.directory"
    # The <Name> our own menus carry, distinct from the root_menu_name argument
    # ("Applications") naming the menu we graft onto.
    MENU_ID = "BlackArch"

    def __init__(
        self,
        layout: Layout,
        session: "Session | None" = None,
        dry_run: bool = False,
        verbose: bool = False,
    ):
        self.layout = layout
        self.session = session or Session.detect()
        self.dry_run = dry_run
        self.verbose = verbose
        self.written: list[Path] = []

    # -- helpers ----------------------------------------------------------- #

    def _write(self, path: Path, content: str) -> None:
        self.written.append(path)
        if self.verbose:
            print(f"  {path}")
        if self.dry_run:
            return
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content, encoding="utf-8")
        # `sudo` without --system still writes into the desktop user's home, so
        # give the files back rather than leaving root-owned ones behind.
        self.session.claim(path)

    def exec_line(self, tool: Tool) -> str:
        kind, value = tool.exec_command[0], tool.exec_command[1]
        if kind == "@raw":
            # Mirrored from the package's own .desktop file; leave it alone.
            return value
        if kind == "@browse":
            return f"{BROWSE_COMMAND} {quote_exec_arg(value)}"
        # Bare command, no arguments: a menu editor then shows the binary as the
        # program with an empty argument list.
        return quote_exec_arg(value)

    # -- generation -------------------------------------------------------- #

    def desktop_file_content(self, tool: Tool) -> str:
        categories = ["X-BlackArch"] + [category_for(g) for g in tool.groups]
        keywords = ["blackarch", "security", "pentest"] + tool.groups
        lines = [
            "[Desktop Entry]",
            "Type=Application",
            "Version=1.0",
            f"Name={escape_value(tool.display_name)}",
        ]
        if tool.description:
            lines.append(f"Comment={escape_value(tool.description)}")
        lines.append(f"Exec={self.exec_line(tool)}")
        lines.append(f"Icon={tool.icon or GROUP_ICONS.get(tool.groups[0], FALLBACK_ICON)}")
        lines += [
            f"Terminal={'true' if tool.terminal else 'false'}",
            "Categories=" + ";".join(categories) + ";",
            "Keywords=" + ";".join(dict.fromkeys(keywords)) + ";",
            f"X-BlackArch-Package={tool.package}",
        ]
        return "\n".join(lines) + "\n"

    def directory_file_content(self, name: str, icon: str, comment: str) -> str:
        return (
            "[Desktop Entry]\n"
            "Type=Directory\n"
            f"Name={escape_value(name)}\n"
            f"Comment={escape_value(comment)}\n"
            f"Icon={icon}\n"
        )

    def menu_file_content(
        self, groups: list[str], root_menu_name: str, nested: bool = False
    ) -> str:
        """The merged XML fragment.

        Nested puts every group under one "BlackArch" parent, which only the
        cascading launchers can render. Flat hangs the groups off the root menu
        directly, next to Development/Games/..., because Kickoff and the Cinnamon
        applet only ever draw top-level menus (see `nested` in generate()).
        """
        parts = [MENU_HEADER, "<Menu>", f"\t<Name>{xml_escape(root_menu_name)}</Name>"]
        indent = "\t\t" if nested else "\t"
        if nested:
            parts += [
                "",
                "\t<Menu>",
                f"\t\t<Name>{self.MENU_ID}</Name>",
                f"\t\t<Directory>{self.ROOT_DIRECTORY}</Directory>",
            ]
        for group in groups:
            name = xml_escape(group)
            parts += [
                "",
                f"{indent}<Menu>",
                f"{indent}\t<Name>{self.MENU_ID}-{name}</Name>",
                f"{indent}\t<Directory>blackarch-{name}.directory</Directory>",
                f"{indent}\t<Include>",
                f"{indent}\t\t<Category>{xml_escape(category_for(group))}</Category>",
                f"{indent}\t</Include>",
                f"{indent}</Menu>",
            ]
        if nested:
            parts.append("\t</Menu>")
        parts += ["</Menu>", ""]
        return "\n".join(parts)

    def generate(
        self,
        tools: list[Tool],
        root_menu_name: str = "Applications",
        nested: bool = False,
    ) -> None:
        """Write every file for `tools`.

        With `nested`, the groups sit under a single "BlackArch" menu -- the tidier
        tree, but Plasma's Kickoff and Cinnamon's menu applet both flatten anything
        below the top level, so the groups vanish and you get one huge undivided
        BlackArch category. Flat (the default) names each group menu "BlackArch
        <Group>" and hangs it off the root, which every launcher can draw.
        """
        groups = sorted({g for tool in tools for g in tool.groups})
        self.remove_stale()

        for tool in tools:
            target = self.layout.applications / f"{tool.package}.desktop"
            self._write(target, self.desktop_file_content(tool))

        if nested:
            # Only the nested layout has a parent menu to title.
            self._write(
                self.layout.directories / self.ROOT_DIRECTORY,
                self.directory_file_content(
                    "BlackArch",
                    ROOT_ICON,
                    "Penetration testing tools installed from BlackArch",
                ),
            )
        for group in groups:
            count = sum(1 for t in tools if group in t.groups)
            self._write(
                self.layout.directories / f"blackarch-{group}.directory",
                self.directory_file_content(
                    group_label(group, nested=nested),
                    GROUP_ICONS.get(group, FALLBACK_ICON),
                    f"BlackArch {pretty_group(group)} tools ({count} installed)",
                ),
            )

        menu_xml = self.menu_file_content(groups, root_menu_name, nested=nested)
        for merge_dir in self.layout.merge_dirs:
            self._write(merge_dir / self.MENU_FILENAME, menu_xml)

    # -- removal ----------------------------------------------------------- #

    def remove_stale(self) -> None:
        """Drop files an earlier version of the generator left behind.

        Regenerating after tools are uninstalled, or after a change to how entries
        are built, would otherwise leave orphans pointing at things that no longer
        exist. Earlier versions wrote launcher wrapper scripts; entries now invoke
        the command directly, so that directory is removed outright.
        """
        stale: list[Path] = [self.layout.legacy_helpers]
        if self.layout.applications.is_dir():
            stale += sorted(self.layout.applications.glob("*.desktop"))
        if self.layout.directories.is_dir():
            stale.append(self.layout.directories / self.ROOT_DIRECTORY)
            stale += sorted(self.layout.directories.glob("blackarch-*.directory"))
        for path in stale:
            if not path.exists() or self.dry_run:
                continue
            if path.is_dir():
                shutil.rmtree(path)
            else:
                path.unlink()

    def installed_paths(self) -> list[Path]:
        """Every path a previous run under this layout left behind."""
        targets: list[Path] = [self.layout.applications, self.layout.legacy_helpers]
        # Sweep every *-merged directory rather than only the ones this front-end
        # writes: an earlier version, or another desktop's front-end, may have left
        # a fragment behind, and an orphaned one keeps a half-dead BlackArch menu
        # on screen long after everything it points at is gone.
        for root in dict.fromkeys(d.parent for d in self.layout.merge_dirs):
            if root.is_dir():
                targets += sorted(root.glob(f"*-merged/{self.MENU_FILENAME}"))
        targets += [d / self.MENU_FILENAME for d in self.layout.merge_dirs]
        if self.layout.directories.is_dir():
            targets.append(self.layout.directories / self.ROOT_DIRECTORY)
            targets += sorted(self.layout.directories.glob("blackarch-*.directory"))
        # Dedupe by what a path points at, not by how it is spelled: distros ship
        # cinnamon-applications-merged as a symlink to applications-merged, so one
        # fragment turns up twice and the second unlink would fail.
        unique: dict[Path, Path] = {}
        for path in targets:
            if path.exists():
                unique.setdefault(path.resolve(), path)
        return list(unique.values())

    def uninstall(self) -> list[Path]:
        removed = self.installed_paths()
        if self.dry_run:
            return removed
        for target in removed:
            if target.is_dir():
                shutil.rmtree(target)
            else:
                target.unlink()
        return removed


def uninstall_all(
    layouts: list[Layout], dry_run: bool = False
) -> tuple[list[Path], list[Path]]:
    """Remove generated files from every layout, reporting what needs root.

    Nothing records whether an install was user-level or system-wide, so removal
    sweeps both instead of failing quietly when the user does not repeat the flag
    they installed with. Returns (removed, needs_root).
    """
    removed: list[Path] = []
    needs_root: list[Path] = []
    for layout in layouts:
        generator = Generator(layout, dry_run=dry_run)
        if layout.system_wide and os.geteuid() != 0:
            needs_root += generator.installed_paths()
        else:
            removed += generator.uninstall()
    return removed, needs_root


@dataclass
class Session:
    """The desktop user, even when the script is running under sudo.

    A `--system` install needs root to write /usr/share, but the menu cache and
    the menu editor's overrides live in the desktop user's home. Rebuilding root's
    cache instead is the usual reason a system-wide install "does nothing".
    """

    home: Path
    uid: int
    gid: int
    name: str

    @property
    def elevated(self) -> bool:
        """True when we are root but acting for somebody else."""
        return os.geteuid() == 0 and self.uid != 0

    @classmethod
    def detect(cls) -> "Session":
        sudo_uid = os.environ.get("SUDO_UID")
        if os.geteuid() == 0 and sudo_uid:
            entry = pwd.getpwuid(int(sudo_uid))
            return cls(Path(entry.pw_dir), entry.pw_uid, entry.pw_gid, entry.pw_name)
        # $USER is unset in a non-login shell, and the name is what runuser needs.
        entry = pwd.getpwuid(os.geteuid())
        return cls(Path.home(), entry.pw_uid, entry.pw_gid, entry.pw_name)

    def _xdg(self, variable: str, fallback: str) -> Path:
        # Only trust the environment when it belongs to the user we are acting for;
        # under sudo it still describes root.
        value = os.environ.get(variable)
        if value and not self.elevated:
            return Path(value)
        return self.home / fallback

    @property
    def config(self) -> Path:
        return self._xdg("XDG_CONFIG_HOME", ".config")

    @property
    def cache(self) -> Path:
        return self._xdg("XDG_CACHE_HOME", ".cache")

    @property
    def data(self) -> Path:
        return self._xdg("XDG_DATA_HOME", ".local/share")

    def claim(self, path: Path) -> None:
        """Hand anything we wrote as root back to the user who owns the home dir.

        Walks up to the home directory, because the parent directories may have
        been created by the same root-side run. A file left owned by root locks
        the user out of every later unprivileged run.
        """
        while self.elevated and self.home in path.parents:
            os.chown(path, self.uid, self.gid)
            path = path.parent


def refresh_caches(
    commands: list[list[str]], dry_run: bool = False, session: Session | None = None
) -> None:
    """Run the DE's menu-cache rebuilders, ignoring ones that are not installed.

    Under sudo they are printed rather than run. kbuildsycoca rebuilds the cache of
    whoever invokes it, and the cache file is keyed by a hash of the XDG paths --
    which sudo does not carry over -- so a root-side rebuild writes a cache the
    session never reads and cannot notify the running shell that it changed. Doing
    it anyway is how a system-wide install ends up with an empty launcher.
    """
    session = session or Session.detect()
    runnable = [command for command in commands if shutil.which(command[0])]
    if session.elevated:
        print("\nRun these as your desktop user to pick the menu up:")
        for command in runnable:
            print(f"  {' '.join(command)}")
        return
    for command in runnable:
        if dry_run:
            print(f"  would run: {' '.join(command)}")
            continue
        result = subprocess.run(
            command,
            check=False,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.PIPE,
            text=True,
        )
        if result.returncode != 0:
            # Silently swallowing this is how a failed rebuild looks identical to
            # a successful one from the outside.
            detail = result.stderr.strip().splitlines()
            print(f"warning: {command[0]} failed: {detail[-1] if detail else ''}")


# --------------------------------------------------------------------------- #
# repairing a dirty menu state
# --------------------------------------------------------------------------- #

# The generated files are only half the story: a desktop's menu editor and any
# stale fragment left lying around both sit downstream of them and can hide a menu
# that was written perfectly. The caches are deliberately not touched -- deleting
# the live one while the desktop is running leaves the session with no menu at all
# until it is rebuilt, and a --noincremental rebuild does the same job safely.
#
# The worst of them is the menu editor. plasma-applications.menu ends with
# <MergeFile>applications-kmenuedit.menu</MergeFile>, so whatever kmenuedit saved
# there is merged last and beats every fragment we write; Cinnamon's and GNOME's
# editors write a full override copy of the menu file with the same effect. Saving
# in an editor while our menus are absent -- mid-uninstall, say -- records them as
# <Deleted/>, and from then on regenerating cannot bring them back, because
# <Deleted/> also hides them from the editor: there is nothing left in the UI to
# undelete.
#
# kmenuedit hides a single entry by excluding its .desktop from the menu it lives
# in and filing it under a menu literally named ".hidden"; it hides a whole submenu
# with <Deleted/>. Both survive a reinstall, so both have to be undone here.
HIDDEN_MENU = ".hidden"


def _owns_menu(name: str) -> bool:
    return name == Generator.MENU_ID or name.startswith(f"{Generator.MENU_ID}-")


def _owns_entry(filename: str) -> bool:
    # Matches our own <group>-prefixed ids and anything a previous BlackArch menu
    # installed, which is what an old override is most likely to name.
    return filename.lower().startswith("blackarch")


def _prune_filenames(parent: ElementTree.Element, tag: str) -> list[str]:
    """Drop our .desktop ids out of every <tag> child, emptying it if need be."""
    dropped: list[str] = []
    for holder in parent.findall(tag):
        for element in list(holder):
            name = (element.text or "").strip()
            if element.tag == "Filename" and _owns_entry(name):
                holder.remove(element)
                dropped.append(name)
        if len(holder) == 0:
            parent.remove(holder)
    return dropped


def _prune_overrides(parent: ElementTree.Element) -> list[str]:
    """Strip a menu editor's hide/delete overrides for anything of ours, depth first."""
    dropped: list[str] = []
    for name in _prune_filenames(parent, "Exclude"):
        dropped.append(f"entry {name}")
    for child in list(parent):
        if child.tag != "Menu":
            continue
        name = (child.findtext("Name") or "").strip()
        if _owns_menu(name) and child.find("Deleted") is not None:
            parent.remove(child)
            dropped.append(f"menu {name}")
            continue
        if name == HIDDEN_MENU:
            # Emptying its <Include> is enough; the menu itself is not ours.
            for hidden in _prune_filenames(child, "Include"):
                dropped.append(f"entry {hidden}")
        else:
            dropped += _prune_overrides(child)
        # A menu left holding nothing but its own name no longer says anything.
        if (_owns_menu(name) or name == HIDDEN_MENU) and all(
            sub.tag == "Name" for sub in child
        ):
            parent.remove(child)
    return dropped


def _is_hidden_entry(path: Path) -> bool:
    entry = parse_desktop_entry(path)
    return "true" in (
        entry.get("Hidden", "").lower(),
        entry.get("NoDisplay", "").lower(),
    )


class Repair:
    """Finds and undoes the things that hide a correctly generated menu."""

    def __init__(
        self,
        layout: Layout,
        session: Session | None = None,
        dry_run: bool = False,
    ):
        self.layout = layout
        self.session = session or Session.detect()
        self.dry_run = dry_run
        self.actions: list[str] = []

    def _note(self, message: str) -> None:
        self.actions.append(message)

    # -- the four sources of a dirty state --------------------------------- #

    def undo_editor_overrides(self) -> None:
        """Undo menu-editor hides and deletions of ours in every override file.

        kmenuedit writes applications-kmenuedit.menu; cinnamon-menu-editor and
        alacarte write a full copy of the menu file itself. All of them live
        directly in ~/.config/menus, so that is what we sweep.
        """
        menus = self.session.config / "menus"
        if not menus.is_dir():
            return
        for path in sorted(menus.glob("*.menu")):
            try:
                # These are the user's files, not ours; keep their comments, which
                # a default parse would silently drop on the way back out.
                tree = ElementTree.parse(
                    path,
                    ElementTree.XMLParser(
                        target=ElementTree.TreeBuilder(insert_comments=True)
                    ),
                )
            except (ElementTree.ParseError, OSError):
                continue  # not ours to repair
            dropped = list(dict.fromkeys(_prune_overrides(tree.getroot())))
            if not dropped:
                continue
            self._note(f"unhid {', '.join(dropped)} in {path}")
            if self.dry_run:
                continue
            backup = path.with_name(path.name + ".bak")
            shutil.copyfile(path, backup)
            self.session.claim(backup)
            body = ElementTree.tostring(tree.getroot(), encoding="unicode")
            path.write_text(MENU_DOCTYPE + body + "\n", encoding="utf-8")
            self.session.claim(path)

    def unhide_entries(self) -> None:
        """Drop user overrides that hide one of our entries.

        Hiding an application in a menu editor shadows it with a user-level
        .desktop carrying Hidden=true, which outranks the entry we install.
        """
        user_apps = self.session.data / "applications"
        if not user_apps.is_dir():
            return
        candidates = list(user_apps.glob("blackarch-*.desktop"))
        candidates += list(user_apps.glob("blackarch/*.desktop"))
        for path in sorted(set(candidates)):
            if path.parent == self.layout.applications:
                continue  # a file we generate, not an override of one
            if not _is_hidden_entry(path):
                continue
            self._note(f"removed hidden-entry override {path}")
            if not self.dry_run:
                path.unlink()

    def disable_broken_fragments(self) -> None:
        """Move aside BlackArch .menu fragments that are not well-formed XML.

        A fragment that fails to parse is dropped whole by the menu builder, so a
        stale broken one can take working entries down with it. Only fragments in
        the BlackArch namespace are touched, and they are renamed rather than
        deleted.
        """
        for merge_dir in self.layout.merge_dirs:
            if not merge_dir.is_dir():
                continue
            for fragment in sorted(merge_dir.glob("blackarch*.menu")):
                try:
                    ElementTree.parse(fragment)
                    continue
                except ElementTree.ParseError:
                    pass
                except OSError:
                    continue
                disabled = fragment.with_name(fragment.name + ".disabled")
                self._note(f"disabled malformed fragment {fragment} -> {disabled.name}")
                if not self.dry_run:
                    fragment.replace(disabled)

    # -- driver ------------------------------------------------------------ #

    def run(self) -> list[str]:
        self.undo_editor_overrides()
        self.unhide_entries()
        self.disable_broken_fragments()
        return self.actions


def render_tree(
    tools: list[Tool], show_tools: bool = False, nested: bool = False
) -> str:
    """Draw the menu that would be created, as a tree.

    The tool counts are only here to show what was detected per group; they do not
    appear anywhere in the generated menu.
    """
    by_group: dict[str, list[Tool]] = {}
    for tool in tools:
        for group in tool.groups:
            by_group.setdefault(group, []).append(tool)

    lines = ["Menu structure will look as follows:", ""]
    if nested:
        lines.append("*BlackArch*")
    else:
        lines.append("*Application launcher*")
    groups = sorted(by_group, key=pretty_group)
    for index, group in enumerate(groups):
        last_group = index == len(groups) - 1
        members = sorted(by_group[group], key=lambda t: t.display_name.lower())
        plural = "tool" if len(members) == 1 else "tools"
        lines.append(
            f"{'└──' if last_group else '├──'} {group_label(group, nested=nested)} "
            f"({len(members)} {plural})"
        )
        if not show_tools:
            continue
        stem = "    " if last_group else "│   "
        for position, tool in enumerate(members):
            branch = "└──" if position == len(members) - 1 else "├──"
            lines.append(f"{stem}{branch} {tool.display_name}")
    return "\n".join(lines)


def summarise(
    tools: list[Tool],
    skipped: list[str],
    show_tools: bool = False,
    nested: bool = False,
) -> None:
    groups = {group for tool in tools for group in tool.groups}
    print()
    print(render_tree(tools, show_tools=show_tools, nested=nested))
    print(
        f"\n{len(groups)} submenus, {len(tools)} tools "
        f"({sum(len(t.groups) for t in tools)} entries; tools in several groups "
        f"appear in each)."
    )
    if skipped:
        print(
            f"\nSkipped {len(skipped)} package(s) with no launchable command "
            f"or no topical group:\n  " + ", ".join(skipped)
        )


def require_writable(layout: Layout) -> None:
    if layout.system_wide and os.geteuid() != 0:
        sys.exit("System-wide install needs root. Re-run with sudo, or drop --system.")
    for target in (layout.applications, layout.directories, *layout.merge_dirs):
        # Nothing under a user install is created until write time, so check the
        # nearest directory that does exist.
        existing = target
        while not existing.exists():
            existing = existing.parent
        if not os.access(existing, os.W_OK):
            sys.exit(
                f"{existing} is not writable by you. An earlier run under sudo "
                f"most likely left it owned by another user; hand it back with:\n"
                f"  sudo chown -R $USER: {existing}"
            )
