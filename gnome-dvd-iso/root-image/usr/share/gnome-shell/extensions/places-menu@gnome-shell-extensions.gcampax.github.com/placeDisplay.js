// -*- mode: js; js-indent-level: 4; indent-tabs-mode: nil -*-

const GLib = imports.gi.GLib;
const Gio = imports.gi.Gio;
const Shell = imports.gi.Shell;
const Lang = imports.lang;
const Mainloop = imports.mainloop;
const Signals = imports.signals;
const St = imports.gi.St;

const DND = imports.ui.dnd;
const Main = imports.ui.main;
const Params = imports.misc.params;
const Search = imports.ui.search;
const Util = imports.misc.util;

const Gettext = imports.gettext.domain('gnome-shell-extensions');
const _ = Gettext.gettext;
const N_ = function(x) { return x; }

const Hostname1Iface = <interface name="org.freedesktop.hostname1">
<property name="PrettyHostname" type="s" access="read" />
</interface>;
const Hostname1 = Gio.DBusProxy.makeProxyWrapper(Hostname1Iface);

const PlaceInfo = new Lang.Class({
    Name: 'PlaceInfo',

    _init: function(kind, file, name, icon) {
        this.kind = kind;
        this.file = file;
        this.name = name || this._getFileName();
        this.icon = icon ? new Gio.ThemedIcon({ name: icon }) : this.getIcon();
    },

    destroy: function() {
    },

    isRemovable: function() {
        return false;
    },

    launch: function(timestamp) {
        let launchContext = global.create_app_launch_context();
        launchContext.set_timestamp(timestamp);

        try {
            Gio.AppInfo.launch_default_for_uri(this.file.get_uri(),
                                               launchContext);
        } catch(e if e.matches(Gio.IOErrorEnum, Gio.IOErrorEnum.NOT_MOUNTED)) {
            this.file.mount_enclosing_volume(0, null, null, function(file, result) {
                file.mount_enclosing_volume_finish(result);
                Gio.AppInfo.launch_default_for_uri(file.get_uri(), launchContext);
            });
        } catch(e) {
            Main.notifyError(_("Failed to launch \"%s\"").format(this.name), e.message);
        }
    },

    getIcon: function() {
        try {
            let info = this.file.query_info('standard::symbolic-icon', 0, null);
	    return info.get_symbolic_icon();
        } catch(e if e instanceof Gio.IOErrorEnum) {
            // return a generic icon for this kind
            switch (this.kind) {
            case 'network':
                return new Gio.ThemedIcon({ name: 'folder-remote-symbolic' });
            case 'devices':
                return new Gio.ThemedIcon({ name: 'drive-harddisk-symbolic' });
            case 'special':
            case 'bookmarks':
            default:
                if (!this.file.is_native())
                    return new Gio.ThemedIcon({ name: 'folder-remote-symbolic' });
                else
                    return new Gio.ThemedIcon({ name: 'folder-symbolic' });
            }
        }
    },

    _getFileName: function() {
        try {
            let info = this.file.query_info('standard::display-name', 0, null);
            return info.get_display_name();
        } catch(e if e instanceof Gio.IOErrorEnum) {
            return this.file.get_basename();
        }
    },
});
Signals.addSignalMethods(PlaceInfo.prototype);

const RootInfo = new Lang.Class({
    Name: 'RootInfo',
    Extends: PlaceInfo,

    _init: function() {
        this.parent('devices', Gio.File.new_for_path('/'), _("Computer"));

        this._proxy = new Hostname1(Gio.DBus.system,
                                    'org.freedesktop.hostname1',
                                    '/org/freedesktop/hostname1',
                                    Lang.bind(this, function(obj, error) {
                                        if (error)
                                            return;

                                        this._proxy.connect('g-properties-changed',
                                                            Lang.bind(this, this._propertiesChanged));
                                        this._propertiesChanged(obj);
                                    }));
    },

    getIcon: function() {
        return new Gio.ThemedIcon({ name: 'drive-harddisk-symbolic' });
    },

    _propertiesChanged: function(proxy) {
        // GDBusProxy will emit a g-properties-changed when hostname1 goes down
        // ignore it
        if (proxy.g_name_owner) {
            this.name = proxy.PrettyHostname || _("Computer");
            this.emit('changed');
        }
    },

    destroy: function() {
        this._proxy.run_dispose();
        this.parent();
    }
});


const PlaceDeviceInfo = new Lang.Class({
    Name: 'PlaceDeviceInfo',
    Extends: PlaceInfo,

    _init: function(kind, mount) {
        this._mount = mount;
        this.parent(kind, mount.get_root(), mount.get_name());
    },

    getIcon: function() {
        return this._mount.get_symbolic_icon();
    }
});

const PlaceVolumeInfo = new Lang.Class({
    Name: 'PlaceVolumeInfo',
    Extends: PlaceInfo,

    _init: function(kind, volume) {
        this._volume = volume;
        this.parent(kind, volume.get_activation_root(), volume.get_name());
    },

    launch: function(timestamp) {
        if (this.file) {
            this.parent(timestamp);
            return;
        }

        this._volume.mount(0, null, null, Lang.bind(this, function(volume, result) {
            volume.mount_finish(result);

            let mount = volume.get_mount();
            this.file = mount.get_root();
            this.parent(timestamp);
        }));
    },

    getIcon: function() {
        return this._volume.get_symbolic_icon();
    }
});

const DEFAULT_DIRECTORIES = [
    GLib.UserDirectory.DIRECTORY_DOCUMENTS,
    GLib.UserDirectory.DIRECTORY_PICTURES,
    GLib.UserDirectory.DIRECTORY_MUSIC,
    GLib.UserDirectory.DIRECTORY_DOWNLOAD,
    GLib.UserDirectory.DIRECTORY_VIDEOS,
];

const PlacesManager = new Lang.Class({
    Name: 'PlacesManager',

    _init: function() {
        this._places = {
            special: [],
            devices: [],
            bookmarks: [],
            network: [],
        };

        let homePath = GLib.get_home_dir();

        this._places.special.push(new PlaceInfo('special',
                                                Gio.File.new_for_path(homePath),
                                                _("Home")));

        let specials = [];
        for (let i = 0; i < DEFAULT_DIRECTORIES.length; i++) {
            let specialPath = GLib.get_user_special_dir(DEFAULT_DIRECTORIES[i]);
            if (specialPath == homePath)
                continue;

            let file = Gio.File.new_for_path(specialPath), info;
            try {
                info = new PlaceInfo('special', file);
            } catch(e if e.matches(Gio.IOErrorEnum, Gio.IOErrorEnum.NOT_FOUND)) {
                continue;
            }

            specials.push(info);
        }

        specials.sort(function(a, b) {
            return GLib.utf8_collate(a.name, b.name);
        });
        this._places.special = this._places.special.concat(specials);

        /*
        * Show devices, code more or less ported from nautilus-places-sidebar.c
        */
        this._volumeMonitor = Gio.VolumeMonitor.get();
        this._connectVolumeMonitorSignals();
        this._updateMounts();

        this._bookmarksFile = this._findBookmarksFile()
        this._bookmarkTimeoutId = 0;
        this._monitor = null;

        if (this._bookmarksFile) {
            this._monitor = this._bookmarksFile.monitor_file(Gio.FileMonitorFlags.NONE, null);
            this._monitor.connect('changed', Lang.bind(this, function () {
                if (this._bookmarkTimeoutId > 0)
                    return;
                /* Defensive event compression */
                this._bookmarkTimeoutId = Mainloop.timeout_add(100, Lang.bind(this, function () {
                    this._bookmarkTimeoutId = 0;
                    this._reloadBookmarks();
                    return false;
                }));
            }));

            this._reloadBookmarks();
        }
    },

    _connectVolumeMonitorSignals: function() {
        const signals = ['volume-added', 'volume-removed', 'volume-changed',
                         'mount-added', 'mount-removed', 'mount-changed',
                         'drive-connected', 'drive-disconnected', 'drive-changed'];

        this._volumeMonitorSignals = [];
        let func = Lang.bind(this, this._updateMounts);
        for (let i = 0; i < signals.length; i++) {
            let id = this._volumeMonitor.connect(signals[i], func);
            this._volumeMonitorSignals.push(id);
        }
    },

    destroy: function() {
        for (let i = 0; i < this._volumeMonitorSignals.length; i++)
            this._volumeMonitor.disconnect(this._volumeMonitorSignals[i]);

        if (this._monitor)
            this._monitor.cancel();
        if (this._bookmarkTimeoutId)
            Mainloop.source_remove(this._bookmarkTimeoutId);
    },

    _updateMounts: function() {
        let networkMounts = [];
        let networkVolumes = [];

        this._places.devices.forEach(function (p) { p.destroy(); });
        this._places.devices = [];
        this._places.network.forEach(function (p) { p.destroy(); });
        this._places.network = [];

        /* Add standard places */
        this._places.devices.push(new RootInfo());
        this._places.network.push(new PlaceInfo('network',
                                                Gio.File.new_for_uri('network:///'),
                                                _("Browse Network"),
                                                'network-workgroup-symbolic'));

        /* first go through all connected drives */
        let drives = this._volumeMonitor.get_connected_drives();
        for (let i = 0; i < drives.length; i++) {
            let volumes = drives[i].get_volumes();

            for(let j = 0; j < volumes.length; j++) {
                let identifier = volumes[j].get_identifier('class');
                if (identifier && identifier.indexOf('network') >= 0) {
                    networkVolumes.push(volumes[j]);
                } else {
                    let mount = volumes[j].get_mount();
                    if(mount != null)
                        this._addMount('devices', mount);
                }
            }
        }

        /* add all volumes that is not associated with a drive */
        let volumes = this._volumeMonitor.get_volumes();
        for(let i = 0; i < volumes.length; i++) {
            if(volumes[i].get_drive() != null)
                continue;

            let identifier = volumes[i].get_identifier('class');
            if (identifier && identifier.indexOf('network') >= 0) {
                networkVolumes.push(volumes[i]);
            } else {
                let mount = volumes[i].get_mount();
                if(mount != null)
                    this._addMount('devices', mount);
            }
        }

        /* add mounts that have no volume (/etc/mtab mounts, ftp, sftp,...) */
        let mounts = this._volumeMonitor.get_mounts();
        for(let i = 0; i < mounts.length; i++) {
            if(mounts[i].is_shadowed())
                continue;

            if(mounts[i].get_volume())
                continue;

            let root = mounts[i].get_default_location();
            if (!root.is_native()) {
                networkMounts.push(mounts[i]);
                continue;
            }
            this._addMount('devices', mounts[i]);
        }

        for (let i = 0; i < networkVolumes.length; i++) {
            let mount = networkVolumes[i].get_mount();
            if (mount) {
                networkMounts.push(mount);
                continue;
            }
            this._addVolume('network', networkVolumes[i]);
        }

        for (let i = 0; i < networkMounts.length; i++) {
            this._addMount('network', networkMounts[i]);
        }

        this.emit('devices-updated');
        this.emit('network-updated');
    },

    _findBookmarksFile: function() {
        let paths = [
            GLib.build_filenamev([GLib.get_user_config_dir(), 'gtk-3.0', 'bookmarks']),
            GLib.build_filenamev([GLib.get_home_dir(), '.gtk-bookmarks']),
        ];

        for (let i = 0; i < paths.length; i++) {
            if (GLib.file_test(paths[i], GLib.FileTest.EXISTS))
                return Gio.File.new_for_path(paths[i]);
        }

        return null;
    },

    _reloadBookmarks: function() {

        this._bookmarks = [];

        let content = Shell.get_file_contents_utf8_sync(this._bookmarksFile.get_path());
        let lines = content.split('\n');

        let bookmarks = [];
        for (let i = 0; i < lines.length; i++) {
            let line = lines[i];
            let components = line.split(' ');
            let bookmark = components[0];

            if (!bookmark)
                continue;

            let file = Gio.File.new_for_uri(bookmark);
            if (file.is_native() && !file.query_exists(null))
                continue;

            let duplicate = false;
            for (let i = 0; i < this._places.special.length; i++) {
                if (file.equal(this._places.special[i].file)) {
                    duplicate = true;
                    break;
                }
            }
            if (duplicate)
                continue;
            for (let i = 0; i < bookmarks.length; i++) {
                if (file.equal(bookmarks[i].file)) {
                    duplicate = true;
                    break;
                }
            }
            if (duplicate)
                continue;

            let label = null;
            if (components.length > 1)
                label = components.slice(1).join(' ');

            bookmarks.push(new PlaceInfo('bookmarks', file, label));
        }

        this._places.bookmarks = bookmarks;

        this.emit('bookmarks-updated');
    },

    _addMount: function(kind, mount) {
        let devItem;

        try {
            devItem = new PlaceDeviceInfo(kind, mount);
        } catch(e if e.matches(Gio.IOErrorEnum, Gio.IOErrorEnum.NOT_FOUND)) {
            return;
        }

        this._places[kind].push(devItem);
    },

    _addVolume: function(kind, volume) {
        let volItem;

        try {
            volItem = new PlaceVolumeInfo(kind, volume);
        } catch(e if e.matches(Gio.IOErrorEnum, Gio.IOErrorEnum.NOT_FOUND)) {
            return;
        }

        this._places[kind].push(volItem);
    },

    get: function (kind) {
        return this._places[kind];
    }
});
Signals.addSignalMethods(PlacesManager.prototype);
