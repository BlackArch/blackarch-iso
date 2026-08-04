# blackarch-menu

Generates the BlackArch section of the Xfce application menu: one submenu per
BlackArch group, listing the tools from that group that are actually installed.

## Why this is here

Xfce draws its menu from XDG `.desktop` files. The ~2900 CLI tools in this image
ship none, so without a generator the launcher shows only the handful of GUI
packages that bring their own entry.

`blackarch-menus` is the upstream answer to that and is still installed (it is a
hard dependency of `blackarch-config-xfce`, and its `.directory` files are used).
Its generator is not used, though, and `customize_airootfs.sh` removes its
fragment and pacman hooks. Two reasons:

* It resolves every package with `pacman -Si blackarch/<pkg>`, so it needs the
  `[blackarch]` repository configured and does one pacman call per package. During
  `pacstrap` the repository is not configured yet, so every lookup fails and it
  writes nothing at all. This is why the menu was empty.
* It writes `TryExec=/usr/bin/<pkg>`, assuming the binary is named after the
  package. Where it is not, the menu silently hides the entry.

This generator reads the local pacman database instead (three batched queries, no
repository, no network) and resolves each package's real binary, mirroring the
package's own `.desktop` file when it ships one and falling back to opening the
package's data directory for tools that are data only.

## Files

| Path | Provenance |
| --- | --- |
| `blackarch_menu.py` | Vendored verbatim from the `BlackarchKdeMenu` repo. Re-vendor with a plain `cp`; keep it byte-identical so upstream fixes apply cleanly. |
| `BlackArchXfceMenuTool.py` | Xfce front-end, written for this ISO. The upstream repo's front-end is Plasma-specific. |
| `regen-menu.sh` | Wrapper for the pacman hook. Always exits 0. |

## Regenerating

The menu is generated at build time by `customize_airootfs.sh`, and again by
`/etc/pacman.d/hooks/blackarch-xfce-menu.hook` after any pacman transaction, so
installing more tools picks them up:

```sh
sudo pacman -S blackarch-wireless
```

To run it by hand:

```sh
sudo python3 /usr/share/blackarch-menu/BlackArchXfceMenuTool.py --system --nested
```

`--nested` (the default) puts the groups inside one `BlackArch` menu. Xfce's
Applications Menu plugin cascades and draws that properly; Whiskermenu, which is
what `blackarch-config-xfce` puts on the panel, draws top-level categories only
and flattens anything below one, so under it the groups collapse into a single
`BlackArch` category. Use `--flat` instead to get them as top-level
`BlackArch Wireless`, `BlackArch Recon`, ... categories in Whiskermenu's sidebar.

`--uninstall` removes everything it generated; `--fix-dirty` clears a menu-editor
override or stale fragment that is hiding the menu. Both are described in
`--help`.
