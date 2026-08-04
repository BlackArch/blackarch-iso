#!/usr/bin/env python3
"""Generate a BlackArch menu for Xfce.

Builds a "BlackArch" entry in the application launcher with one submenu per
BlackArch group (Exploitation, Wireless, Recon, ...), each listing the tools from
that group that are actually installed. Group membership and installed state both
come from pacman's local database, so the menu only ever shows tools you have and
the whole thing works offline -- which is what lets it run inside the ISO build,
where no repository is configured yet.

Usage:
    ./BlackArchXfceMenuTool.py                    # print this usage
    ./BlackArchXfceMenuTool.py --install          # install for the current user
    ./BlackArchXfceMenuTool.py --system           # install for all users (root)
    ./BlackArchXfceMenuTool.py --install --flat   # groups at the top level
    ./BlackArchXfceMenuTool.py --install --dry-run -v   # show what would change
    ./BlackArchXfceMenuTool.py --fix-dirty        # clear a stuck menu state
    ./BlackArchXfceMenuTool.py --uninstall        # remove everything generated

Install more tools with `sudo pacman -S blackarch-<group>`; the pacman hook in
/etc/pacman.d/hooks regenerates the menu afterwards.
"""

from __future__ import annotations

import argparse
import sys

from blackarch_menu import (
    Generator,
    Layout,
    PacmanError,
    Repair,
    Session,
    collect_tools,
    refresh_caches,
    require_writable,
    summarise,
    uninstall_all,
)

# Xfce reads xfce-applications.menu (it sets XDG_MENU_PREFIX=xfce-), but garcon
# does *not* apply that prefix to the merge directory: <DefaultMergeDirs/>
# resolves to "applications-merged", not "xfce-applications-merged". Verified
# against garcon 4.20 -- a fragment dropped in applications-merged/ is picked up,
# an identical one in xfce-applications-merged/ is ignored. It is also where
# blackarch-menus puts its own fragment, so this matches the distro convention.
MERGE_DIRS = ["applications-merged"]

# garcon merges a fragment into the root menu whatever the fragment's own root is
# named, so "Applications" grafts onto xfce-applications.menu even though that
# file is rooted at <Name>Xfce</Name>. Keeping the generic name means the same
# fragment stays valid for any launcher reading the unprefixed applications.menu.
ROOT_MENU_NAME = "Applications"

# Unlike Plasma there is no menu cache to rebuild: garcon watches the menu and
# application directories and reloads when they change. update-desktop-database
# only refreshes the MIME association cache -- not what draws the menu, but
# nothing else refreshes it during an ISO build, where no pacman transaction runs
# to fire the desktop-file-utils hook that normally would.
MENU_CACHE_COMMANDS: list[list[str]] = []


def refresh_commands(layout: Layout) -> list[list[str]]:
    return [
        *MENU_CACHE_COMMANDS,
        ["update-desktop-database", str(layout.applications.parent)],
    ]


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Generate Xfce menu entries for installed BlackArch tools.",
    )
    parser.add_argument(
        "--install",
        action="store_true",
        help="write the menu for the tools installed right now",
    )
    parser.add_argument(
        "--system",
        action="store_true",
        help="install for all users under /usr/share (requires root)",
    )
    parser.add_argument(
        "--uninstall",
        action="store_true",
        help="remove every file a previous run generated",
    )
    parser.add_argument(
        "--fix-dirty",
        action="store_true",
        help="clear a menu-editor override or stale fragment hiding the menu",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="report what would change without touching the filesystem",
    )
    parser.add_argument(
        "-v",
        "--verbose",
        action="store_true",
        help="expand the tree to every tool, and list each file written or removed",
    )
    # Xfce's own Applications Menu plugin cascades, so the groups can sit inside a
    # single BlackArch menu -- the tidier tree, and the shape blackarch-menus uses
    # upstream. Whiskermenu (what blackarch-config-xfce puts on the panel) draws
    # top-level categories only and flattens anything below one, so --flat is there
    # for anyone who wants the groups visible in its sidebar instead.
    shape = parser.add_mutually_exclusive_group()
    shape.add_argument(
        "--nested",
        dest="nested",
        action="store_true",
        help="groups inside one BlackArch menu (default)",
    )
    shape.add_argument(
        "--flat",
        dest="nested",
        action="store_false",
        help='groups at the top level, named "BlackArch Wireless" and so on',
    )
    parser.set_defaults(nested=True)
    args = parser.parse_args()

    installing = args.install or args.system
    if not (installing or args.uninstall or args.fix_dirty):
        # Nothing was asked for. Writing a menu is not what a bare run should do.
        parser.print_help()
        return 0

    session = Session.detect()
    layout = (
        Layout.system(MERGE_DIRS) if args.system else Layout.user(MERGE_DIRS, session)
    )

    if args.uninstall:
        # An install may be user-level or system-wide and nothing on disk records
        # which, so sweep both rather than reporting "removed 0" while a full
        # install sits in /usr/share.
        removed, needs_root = uninstall_all(
            [Layout.user(MERGE_DIRS, session), Layout.system(MERGE_DIRS)],
            dry_run=args.dry_run,
        )
        verb = "Would remove" if args.dry_run else "Removed"
        print(f"{verb} {len(removed)} path(s).")
        if args.verbose:
            for path in removed:
                print(f"  {path}")
        if needs_root:
            print(
                f"\n{len(needs_root)} system-wide path(s) still installed under "
                "/usr/share and /etc/xdg. Re-run with sudo to remove them."
            )
            if args.verbose:
                for path in needs_root:
                    print(f"  {path}")
    elif installing:
        if not args.dry_run:
            require_writable(layout)
        generator = Generator(
            layout, session=session, dry_run=args.dry_run, verbose=args.verbose
        )
        try:
            tools, skipped = collect_tools()
        except PacmanError as exc:
            print(f"error: {exc}", file=sys.stderr)
            return 1

        if not tools:
            print(
                "No BlackArch tools found. Install some with "
                "`sudo pacman -S blackarch-<group>` and re-run."
            )
            return 1

        generator.generate(
            tools, root_menu_name=ROOT_MENU_NAME, nested=args.nested
        )
        summarise(tools, skipped, show_tools=args.verbose, nested=args.nested)
        verb = "Dry run:" if args.dry_run else "Wrote"
        suffix = " would be written" if args.dry_run else ""
        print(f"\n{verb} {len(generator.written)} file(s){suffix}.")

    if args.fix_dirty:
        actions = Repair(layout, session=session, dry_run=args.dry_run).run()
        verb = "Would fix" if args.dry_run else "Fixed"
        print(f"\n{verb} {len(actions)} dirty menu state(s).")
        for action in actions:
            print(f"  {action}")

    refresh_caches(refresh_commands(layout), dry_run=args.dry_run, session=session)
    if not args.dry_run and installing and not session.elevated:
        print("Menu written. If it has not appeared, log out and back in.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
