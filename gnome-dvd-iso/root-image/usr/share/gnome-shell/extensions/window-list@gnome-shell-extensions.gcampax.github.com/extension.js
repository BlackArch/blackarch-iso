const Clutter = imports.gi.Clutter;
const GLib = imports.gi.GLib;
const Gio = imports.gi.Gio;
const Gtk = imports.gi.Gtk;
const Meta = imports.gi.Meta;
const Shell = imports.gi.Shell;
const St = imports.gi.St;

const DND = imports.ui.dnd;
const Hash = imports.misc.hash;
const Lang = imports.lang;
const Main = imports.ui.main;
const MessageTray = imports.ui.messageTray;
const PanelMenu = imports.ui.panelMenu;
const PopupMenu = imports.ui.popupMenu;

const ExtensionUtils = imports.misc.extensionUtils;
const Me = ExtensionUtils.getCurrentExtension();
const Convenience = Me.imports.convenience;

const ICON_TEXTURE_SIZE = 24;
const DND_ACTIVATE_TIMEOUT = 500;

const GroupingMode = {
    NEVER: 0,
    AUTO: 1,
    ALWAYS: 2
};


function _minimizeOrActivateWindow(window) {
        let focusWindow = global.display.focus_window;
        if (focusWindow == window ||
            focusWindow && focusWindow.get_transient_for() == window)
            window.minimize();
        else
            window.activate(global.get_current_time());
}

function _openMenu(menu) {
    menu.open();

    let event = Clutter.get_current_event();
    if (event && event.type() == Clutter.EventType.KEY_RELEASE)
        menu.actor.navigate_focus(null, Gtk.DirectionType.TAB_FORWARD, false);
}


const WindowContextMenu = new Lang.Class({
    Name: 'WindowContextMenu',
    Extends: PopupMenu.PopupMenu,

    _init: function(source, metaWindow) {
        this.parent(source, 0.5, St.Side.BOTTOM);

        this._metaWindow = metaWindow;

        this._minimizeItem = new PopupMenu.PopupMenuItem('');
        this._minimizeItem.connect('activate', Lang.bind(this, function() {
            if (this._metaWindow.minimized)
                this._metaWindow.unminimize();
            else
                this._metaWindow.minimize();
        }));
        this.addMenuItem(this._minimizeItem);

        this._notifyMinimizedId =
            this._metaWindow.connect('notify::minimized',
                                     Lang.bind(this, this._updateMinimizeItem));
        this._updateMinimizeItem();

        this._maximizeItem = new PopupMenu.PopupMenuItem('');
        this._maximizeItem.connect('activate', Lang.bind(this, function() {
            if (this._metaWindow.maximized_vertically &&
                this._metaWindow.maximized_horizontally)
                this._metaWindow.unmaximize(Meta.MaximizeFlags.HORIZONTAL |
                                            Meta.MaximizeFlags.VERTICAL);
            else
                this._metaWindow.maximize(Meta.MaximizeFlags.HORIZONTAL |
                                          Meta.MaximizeFlags.VERTICAL);
        }));
        this.addMenuItem(this._maximizeItem);

        this._notifyMaximizedHId =
            this._metaWindow.connect('notify::maximized-horizontally',
                                     Lang.bind(this, this._updateMaximizeItem));
        this._notifyMaximizedVId =
            this._metaWindow.connect('notify::maximized-vertically',
                                     Lang.bind(this, this._updateMaximizeItem));
        this._updateMaximizeItem();

        let item = new PopupMenu.PopupMenuItem(_("Close"));
        item.connect('activate', Lang.bind(this, function() {
            this._metaWindow.delete(global.get_current_time());
        }));
        this.addMenuItem(item);

        this.actor.connect('destroy', Lang.bind(this, this._onDestroy));
    },

    _updateMinimizeItem: function() {
        this._minimizeItem.label.text = this._metaWindow.minimized ? _("Unminimize")
                                                                   : _("Minimize");
    },

    _updateMaximizeItem: function() {
        let maximized = this._metaWindow.maximized_vertically &&
                        this._metaWindow.maximized_horizontally;
        this._maximizeItem.label.text = maximized ? _("Unmaximize")
                                                  : _("Maximize");
    },

    _onDestroy: function() {
        this._metaWindow.disconnect(this._notifyMinimizedId);
        this._metaWindow.disconnect(this._notifyMaximizedHId);
        this._metaWindow.disconnect(this._notifyMaximizedVId);
    }
});

const WindowTitle = new Lang.Class({
    Name: 'WindowTitle',

    _init: function(metaWindow) {
        this._metaWindow = metaWindow;
        this.actor = new St.BoxLayout();

        let app = Shell.WindowTracker.get_default().get_window_app(metaWindow);
        this._icon = new St.Bin({ style_class: 'window-button-icon',
                                  child: app.create_icon_texture(ICON_TEXTURE_SIZE) });
        this.actor.add(this._icon);
        this._label = new St.Label();
        this.actor.add(this._label);

        this._textureCache = St.TextureCache.get_default();
        this._iconThemeChangedId =
            this._textureCache.connect('icon-theme-changed', Lang.bind(this,
                function() {
                    this._icon.child = app.create_icon_texture(ICON_TEXTURE_SIZE);
                }));
        this.actor.connect('destroy', Lang.bind(this, this._onDestroy));

        this._notifyTitleId =
            this._metaWindow.connect('notify::title',
                                    Lang.bind(this, this._updateTitle));
        this._notifyMinimizedId =
            this._metaWindow.connect('notify::minimized',
                                    Lang.bind(this, this._minimizedChanged));
        this._minimizedChanged();
    },

    _minimizedChanged: function() {
        this._icon.opacity = this._metaWindow.minimized ? 128 : 255;
        this._updateTitle();
    },

    _updateTitle: function() {
        if (this._metaWindow.minimized)
            this._label.text = '[%s]'.format(this._metaWindow.title);
        else
            this._label.text = this._metaWindow.title;
    },

    _onDestroy: function() {
        this._textureCache.disconnect(this._iconThemeChangedId);
        this._metaWindow.disconnect(this._notifyTitleId);
        this._metaWindow.disconnect(this._notifyMinimizedId);
    }
});


const WindowButton = new Lang.Class({
    Name: 'WindowButton',

    _init: function(metaWindow) {
        this.metaWindow = metaWindow;

        this._windowTitle = new WindowTitle(this.metaWindow);
        this.actor = new St.Button({ style_class: 'window-button',
                                     x_fill: true,
                                     can_focus: true,
                                     button_mask: St.ButtonMask.ONE |
                                                  St.ButtonMask.THREE,
                                     child: this._windowTitle.actor });
        this.actor._delegate = this;

        this._menuManager = new PopupMenu.PopupMenuManager(this);
        this._contextMenu = new WindowContextMenu(this.actor, this.metaWindow);
        this._contextMenu.actor.hide();
        this._menuManager.addMenu(this._contextMenu);
        Main.uiGroup.add_actor(this._contextMenu.actor);

        this.actor.connect('allocation-changed',
                           Lang.bind(this, this._updateIconGeometry));
        this.actor.connect('clicked', Lang.bind(this, this._onClicked));
        this.actor.connect('destroy', Lang.bind(this, this._onDestroy));
        this.actor.connect('popup-menu', Lang.bind(this, this._onPopupMenu));

        this._switchWorkspaceId =
            global.window_manager.connect('switch-workspace',
                                          Lang.bind(this, this._updateVisibility));
        this._updateVisibility();

        this._notifyFocusId =
            global.display.connect('notify::focus-window',
                                   Lang.bind(this, this._updateStyle));
        this._updateStyle();
    },

    _onClicked: function(actor, button) {
        if (this._contextMenu.isOpen) {
            this._contextMenu.close();
            return;
        }

        if (button == 1)
            _minimizeOrActivateWindow(this.metaWindow);
        else
            _openMenu(this._contextMenu);
    },

    _onPopupMenu: function(actor) {
        if (this._contextMenu.isOpen)
            return;
        _openMenu(this._contextMenu);
    },

    _updateStyle: function() {
        if (this.metaWindow.minimized)
            this.actor.add_style_class_name('minimized');
        else
            this.actor.remove_style_class_name('minimized');

        if (global.display.focus_window == this.metaWindow)
            this.actor.add_style_class_name('focused');
        else
            this.actor.remove_style_class_name('focused');
    },

    _updateVisibility: function() {
        let workspace = global.screen.get_active_workspace();
        this.actor.visible = this.metaWindow.located_on_workspace(workspace);
    },

    _updateIconGeometry: function() {
        let rect = new Meta.Rectangle();

        [rect.x, rect.y] = this.actor.get_transformed_position();
        [rect.width, rect.height] = this.actor.get_transformed_size();

        this.metaWindow.set_icon_geometry(rect);
    },

    _onDestroy: function() {
        global.window_manager.disconnect(this._switchWorkspaceId);
        global.display.disconnect(this._notifyFocusId);
        this._contextMenu.actor.destroy();
    }
});


const AppContextMenu = new Lang.Class({
    Name: 'AppContextMenu',
    Extends: PopupMenu.PopupMenu,

    _init: function(source, app) {
        this.parent(source, 0.5, St.Side.BOTTOM);

        this._app = app;

        this._minimizeItem = new PopupMenu.PopupMenuItem(_("Minimize all"));
        this._minimizeItem.connect('activate', Lang.bind(this, function() {
            this._app.get_windows().forEach(function(w) {
                w.minimize();
            });
        }));
        this.addMenuItem(this._minimizeItem);

        this._unminimizeItem = new PopupMenu.PopupMenuItem(_("Unminimize all"));
        this._unminimizeItem.connect('activate', Lang.bind(this, function() {
            this._app.get_windows().forEach(function(w) {
                w.unminimize();
            });
        }));
        this.addMenuItem(this._unminimizeItem);

        this._maximizeItem = new PopupMenu.PopupMenuItem(_("Maximize all"));
        this._maximizeItem.connect('activate', Lang.bind(this, function() {
            this._app.get_windows().forEach(function(w) {
                w.maximize(Meta.MaximizeFlags.HORIZONTAL |
                           Meta.MaximizeFlags.VERTICAL);
            });
        }));
        this.addMenuItem(this._maximizeItem);

        this._unmaximizeItem = new PopupMenu.PopupMenuItem(_("Unmaximize all"));
        this._unmaximizeItem.connect('activate', Lang.bind(this, function() {
            this._app.get_windows().forEach(function(w) {
                w.unmaximize(Meta.MaximizeFlags.HORIZONTAL |
                             Meta.MaximizeFlags.VERTICAL);
            });
        }));
        this.addMenuItem(this._unmaximizeItem);

        let item = new PopupMenu.PopupMenuItem(_("Close all"));
        item.connect('activate', Lang.bind(this, function() {
            this._app.get_windows().forEach(function(w) {
                w.delete(global.get_current_time());
            });
        }));
        this.addMenuItem(item);
    },

    open: function(animate) {
        let windows = this._app.get_windows();
        this._minimizeItem.actor.visible = windows.some(function(w) {
            return !w.minimized;
        });
        this._unminimizeItem.actor.visible = windows.some(function(w) {
            return w.minimized;
        });
        this._maximizeItem.actor.visible = windows.some(function(w) {
            return !(w.maximized_horizontally && w.maximized_vertically);
        });
        this._unmaximizeItem.actor.visible = windows.some(function(w) {
            return w.maximized_horizontally && w.maximized_vertically;
        });

        this.parent(animate);
    }
});

const AppButton = new Lang.Class({
    Name: 'AppButton',

    _init: function(app) {
        this.app = app;

        let stack = new St.Widget({ layout_manager: new Clutter.BinLayout() });
        this.actor = new St.Button({ style_class: 'window-button',
                                     x_fill: true,
                                     can_focus: true,
                                     button_mask: St.ButtonMask.ONE |
                                                  St.ButtonMask.THREE,
                                     child: stack });
        this.actor._delegate = this;

        this.actor.connect('allocation-changed',
                           Lang.bind(this, this._updateIconGeometry));

        this._singleWindowTitle = new St.Bin({ x_expand: true,
                                               x_align: St.Align.START });
        stack.add_actor(this._singleWindowTitle);

        this._multiWindowTitle = new St.BoxLayout({ x_expand: true });
        stack.add_actor(this._multiWindowTitle);

        this._icon = new St.Bin({ style_class: 'window-button-icon',
                                  child: app.create_icon_texture(ICON_TEXTURE_SIZE) });
        this._multiWindowTitle.add(this._icon);
        this._multiWindowTitle.add(new St.Label({ text: app.get_name() }));

        this._menuManager = new PopupMenu.PopupMenuManager(this);
        this._menu = new PopupMenu.PopupMenu(this.actor, 0.5, St.Side.BOTTOM);
        this._menu.actor.hide();
        this._menu.connect('activate', Lang.bind(this, this._onMenuActivate));
        this._menuManager.addMenu(this._menu);
        Main.uiGroup.add_actor(this._menu.actor);

        this._contextMenuManager = new PopupMenu.PopupMenuManager(this);
        this._appContextMenu = new AppContextMenu(this.actor, this.app);
        this._appContextMenu.actor.hide();
        this._contextMenuManager.addMenu(this._appContextMenu);
        Main.uiGroup.add_actor(this._appContextMenu.actor);

        this._textureCache = St.TextureCache.get_default();
        this._iconThemeChangedId =
            this._textureCache.connect('icon-theme-changed', Lang.bind(this,
                function() {
                    this._icon.child = app.create_icon_texture(ICON_TEXTURE_SIZE);
                }));
        this.actor.connect('clicked', Lang.bind(this, this._onClicked));
        this.actor.connect('destroy', Lang.bind(this, this._onDestroy));
        this.actor.connect('popup-menu', Lang.bind(this, this._onPopupMenu));

        this._switchWorkspaceId =
            global.window_manager.connect('switch-workspace',
                                          Lang.bind(this, this._updateVisibility));
        this._updateVisibility();

        this._windowsChangedId =
            this.app.connect('windows-changed',
                             Lang.bind(this, this._windowsChanged));
        this._windowsChanged();

        this._windowTracker = Shell.WindowTracker.get_default();
        this._notifyFocusId =
            this._windowTracker.connect('notify::focus-app',
                                        Lang.bind(this, this._updateStyle));
        this._updateStyle();
    },

    _updateVisibility: function() {
        let workspace = global.screen.get_active_workspace();
        this.actor.visible = this.app.is_on_workspace(workspace);
    },

    _updateStyle: function() {
        if (this._windowTracker.focus_app == this.app)
            this.actor.add_style_class_name('focused');
        else
            this.actor.remove_style_class_name('focused');
    },

    _updateIconGeometry: function() {
        let rect = new Meta.Rectangle();

        [rect.x, rect.y] = this.actor.get_transformed_position();
        [rect.width, rect.height] = this.actor.get_transformed_size();

        let windows = this.app.get_windows();
        windows.forEach(function(w) {
            w.set_icon_geometry(rect);
        });
    },


    _getWindowList: function() {
        let workspace = global.screen.get_active_workspace();
        return this.app.get_windows().filter(function(win) {
            return win.located_on_workspace(workspace);
        });
    },

    _windowsChanged: function() {
        let windows = this._getWindowList();
        this._singleWindowTitle.visible = windows.length == 1;
        this._multiWindowTitle.visible = !this._singleWindowTitle.visible;

        if (this._singleWindowTitle.visible) {
            if (!this._windowTitle) {
                this.metaWindow = windows[0];
                this._windowTitle = new WindowTitle(this.metaWindow);
                this._singleWindowTitle.child = this._windowTitle.actor;
                this._windowContextMenu = new WindowContextMenu(this.actor, this.metaWindow);
                Main.uiGroup.add_actor(this._windowContextMenu.actor);
                this._windowContextMenu.actor.hide();
                this._contextMenuManager.addMenu(this._windowContextMenu);
            }
            this._contextMenu = this._windowContextMenu;
        } else {
            if (this._windowTitle) {
                this.metaWindow = null;
                this._singleWindowTitle.child = null;
                this._windowTitle = null;
                this._windowContextMenu.actor.destroy();
                this._windowContextMenu = null;
            }
            this._contextMenu = this._appContextMenu;
        }

    },

    _onClicked: function(actor, button) {
        let menuWasOpen = this._menu.isOpen;
        if (menuWasOpen)
            this._menu.close();

        let contextMenuWasOpen = this._contextMenu.isOpen;
        if (contextMenuWasOpen)
            this._contextMenu.close();

        if (button == 1) {
            if (menuWasOpen)
                return;

            let windows = this._getWindowList();
            if (windows.length == 1) {
                if (contextMenuWasOpen)
                    return;
                _minimizeOrActivateWindow(windows[0]);
            } else {
                this._menu.removeAll();

                for (let i = 0; i < windows.length; i++) {
                    let windowTitle = new WindowTitle(windows[i]);
                    let item = new PopupMenu.PopupBaseMenuItem();
                    item.actor.add_actor(windowTitle.actor);
                    item._window = windows[i];
                    this._menu.addMenuItem(item);
                }
                _openMenu(this._menu);
            }
        } else {
            if (contextMenuWasOpen)
                return;
            _openMenu(this._contextMenu);
        }
    },

    _onPopupMenu: function(actor) {
        if (this._menu.isOpen || this._contextMenu.isOpen)
            return;
        _openMenu(this._contextMenu);
    },


    _onMenuActivate: function(menu, child) {
        child._window.activate(global.get_current_time());
    },

    _onDestroy: function() {
        this._textureCache.disconnect(this._iconThemeChangedId);
        global.window_manager.disconnect(this._switchWorkspaceId);
        this._windowTracker.disconnect(this._notifyFocusId);
        this.app.disconnect(this._windowsChangedId);
        this._menu.actor.destroy();
    }
});


const TrayButton = new Lang.Class({
    Name: 'TrayButton',

    _init: function() {
        this._counterLabel = new St.Label({ x_align: Clutter.ActorAlign.CENTER,
                                            x_expand: true,
                                            y_align: Clutter.ActorAlign.CENTER,
                                            y_expand: true });
        this.actor = new St.Button({ style_class: 'summary-source-counter',
                                     child: this._counterLabel,
                                     layoutManager: new Clutter.BinLayout() });
        this.actor.set_x_align(Clutter.ActorAlign.END);
        this.actor.set_x_expand(true);
        this.actor.set_y_expand(true);

        this.actor.connect('clicked', Lang.bind(this,
            function() {
                if (Main.messageTray._trayState == MessageTray.State.HIDDEN)
                    Main.messageTray.toggle();
            }));
        this.actor.connect('destroy', Lang.bind(this, this._onDestroy));

        this._trayItemCount = 0;
        Main.messageTray.getSources().forEach(Lang.bind(this,
            function(source) {
                this._sourceAdded(Main.messageTray, source);
            }));
        this._sourceAddedId =
            Main.messageTray.connect('source-added',
                                     Lang.bind(this, this._sourceAdded));
        this._sourceRemovedId =
            Main.messageTray.connect('source-removed',
                                     Lang.bind(this, this._sourceRemoved));
        this._updateVisibility();
    },

    _sourceAdded: function(tray, source) {
        this._trayItemCount++;
        this._updateVisibility();
    },

    _sourceRemoved: function(source) {
        this._trayItemCount--;
        this.actor.checked = false;
        this._updateVisibility();
    },

    _updateVisibility: function() {
        this._counterLabel.text = this._trayItemCount.toString();
        this.actor.visible = this._trayItemCount > 0;
    },

    _onDestroy: function() {
        Main.messageTray.getSources().forEach(Lang.bind(this,
            function(source) {
                if (!source._windowListDestroyId)
                    return;
                source.disconnect(source._windowListDestroyId)
                delete source._windowListDestroyId;
            }));
        Main.messageTray.disconnect(this._sourceAddedId);
        Main.messageTray.disconnect(this._sourceRemovedId);
    }
});

const WorkspaceIndicator = new Lang.Class({
    Name: 'WindowList.WorkspaceIndicator',
    Extends: PanelMenu.Button,

    _init: function(){
        this.parent(0.0, _("Workspace Indicator"));
        this.actor.add_style_class_name('window-list-workspace-indicator');

        this._currentWorkspace = global.screen.get_active_workspace().index();
        this.statusLabel = new St.Label({ text: this._getStatusText() });

        this.actor.add_actor(this.statusLabel);

        this.workspacesItems = [];

        this._screenSignals = [];
        this._screenSignals.push(global.screen.connect('notify::n-workspaces', Lang.bind(this,this._updateMenu)));
        this._screenSignals.push(global.screen.connect_after('workspace-switched', Lang.bind(this,this._updateIndicator)));

        this.actor.connect('scroll-event', Lang.bind(this, this._onScrollEvent));
        this._updateMenu();

        this._settings = new Gio.Settings({ schema: 'org.gnome.desktop.wm.preferences' });
        this._settingsChangedId = this._settings.connect('changed::workspace-names', Lang.bind(this, this._updateMenu));
    },

    destroy: function() {
        for (let i = 0; i < this._screenSignals.length; i++)
            global.screen.disconnect(this._screenSignals[i]);

        if (this._settingsChangedId) {
            this._settings.disconnect(this._settingsChangedId);
            this._settingsChangedId = 0;
        }

        this.parent();
    },

    _updateIndicator: function() {
        this.workspacesItems[this._currentWorkspace].setOrnament(PopupMenu.Ornament.NONE);
        this._currentWorkspace = global.screen.get_active_workspace().index();
        this.workspacesItems[this._currentWorkspace].setOrnament(PopupMenu.Ornament.DOT);

        this.statusLabel.set_text(this._getStatusText());
    },

    _getStatusText: function() {
        let current = global.screen.get_active_workspace().index();
        let total = global.screen.n_workspaces;

        return '%d / %d'.format(current + 1, total);
    },

    _updateMenu: function() {
        this.menu.removeAll();
        this.workspacesItems = [];
        this._currentWorkspace = global.screen.get_active_workspace().index();

        for(let i = 0; i < global.screen.n_workspaces; i++) {
            let name = Meta.prefs_get_workspace_name(i);
            let item = new PopupMenu.PopupMenuItem(name);
            item.workspaceId = i;

            item.connect('activate', Lang.bind(this, function(item, event) {
                this._activate(item.workspaceId);
            }));

            if (i == this._currentWorkspace)
                item.setOrnament(PopupMenu.Ornament.DOT);

            this.menu.addMenuItem(item);
            this.workspacesItems[i] = item;
        }

        this.statusLabel.set_text(this._getStatusText());
    },

    _activate: function(index) {
        if(index >= 0 && index < global.screen.n_workspaces) {
            let metaWorkspace = global.screen.get_workspace_by_index(index);
            metaWorkspace.activate(global.get_current_time());
        }
    },

    _onScrollEvent: function(actor, event) {
        let direction = event.get_scroll_direction();
        let diff = 0;
        if (direction == Clutter.ScrollDirection.DOWN) {
            diff = 1;
        } else if (direction == Clutter.ScrollDirection.UP) {
            diff = -1;
        } else {
            return;
        }

        let newIndex = this._currentWorkspace + diff;
        this._activate(newIndex);
    },
});

const WindowList = new Lang.Class({
    Name: 'WindowList',

    _init: function() {
        this.actor = new St.Widget({ name: 'panel',
                                     style_class: 'bottom-panel',
                                     reactive: true,
                                     track_hover: true,
                                     layout_manager: new Clutter.BinLayout()});
        this.actor.connect('destroy', Lang.bind(this, this._onDestroy));

        let box = new St.BoxLayout({ x_expand: true, y_expand: true });
        this.actor.add_actor(box);

        let layout = new Clutter.BoxLayout({ homogeneous: true });
        this._windowList = new St.Widget({ style_class: 'window-list',
                                           layout_manager: layout,
                                           x_align: Clutter.ActorAlign.START,
                                           x_expand: true,
                                           y_expand: true });
        box.add(this._windowList, { expand: true });

        this._windowList.connect('style-changed', Lang.bind(this,
            function() {
                let node = this._windowList.get_theme_node();
                let spacing = node.get_length('spacing');
                this._windowList.layout_manager.spacing = spacing;
            }));
        this._windowList.connect('notify::allocation', Lang.bind(this,
            function() {
                if (this._groupingMode != GroupingMode.AUTO || this._grouped)
                    return;

                let allocation = this._windowList.allocation;
                let width = allocation.x2 - allocation.x1;
                let [, natWidth] = this._windowList.get_preferred_width(-1);
                if (width < natWidth) {
                    this._grouped = true;
                    Meta.later_add(Meta.LaterType.BEFORE_REDRAW,
                                   Lang.bind(this, this._populateWindowList));
                }
            }));

	let indicatorsBox = new St.BoxLayout({ x_align: Clutter.ActorAlign.END });
	box.add(indicatorsBox);

        this._workspaceIndicator = new WorkspaceIndicator();
        indicatorsBox.add(this._workspaceIndicator.container, { expand: false, y_fill: false });

        this._menuManager = new PopupMenu.PopupMenuManager(this);
        this._menuManager.addMenu(this._workspaceIndicator.menu);

        this._trayButton = new TrayButton();
        indicatorsBox.add(this._trayButton.actor, { expand: false });

        Main.layoutManager.addChrome(this.actor, { affectsStruts: true,
                                                   trackFullscreen: true });
        Main.ctrlAltTabManager.addGroup(this.actor, _("Window List"), 'start-here-symbolic');

        this._appSystem = Shell.AppSystem.get_default();
        this._appStateChangedId =
            this._appSystem.connect('app-state-changed',
                                    Lang.bind(this, this._onAppStateChanged));

        this._monitorsChangedId =
            Main.layoutManager.connect('monitors-changed',
                                       Lang.bind(this, this._updatePosition));
        this._updatePosition();

        this._keyboardVisiblechangedId =
            Main.layoutManager.connect('keyboard-visible-changed',
                Lang.bind(this, function(o, state) {
                    Main.layoutManager.keyboardBox.visible = state;
                    Main.uiGroup.set_child_above_sibling(windowList.actor,
                                                         Main.layoutManager.keyboardBox);
                    this._updateKeyboardAnchor();
                }));

        this._workspaceSignals = new Hash.Map();
        this._nWorkspacesChangedId =
            global.screen.connect('notify::n-workspaces',
                                  Lang.bind(this, this._onWorkspacesChanged));
        this._onWorkspacesChanged();

        this._overviewShowingId =
            Main.overview.connect('showing', Lang.bind(this, function() {
                this.actor.hide();
                this._updateKeyboardAnchor();
                this._updateMessageTrayAnchor();
            }));

        this._overviewHidingId =
            Main.overview.connect('hiding', Lang.bind(this, function() {
                this.actor.visible = !Main.layoutManager.primaryMonitor.inFullscreen;
                this._updateKeyboardAnchor();
                this._updateMessageTrayAnchor();
            }));
        this._updateMessageTrayAnchor();

        this._fullscreenChangedId =
            global.screen.connect('in-fullscreen-changed', Lang.bind(this, function() {
                this._updateMessageTrayAnchor();
            }));

        this._dragBeginId =
            Main.xdndHandler.connect('drag-begin',
                                     Lang.bind(this, this._onDragBegin));
        this._dragEndId =
            Main.xdndHandler.connect('drag-end',
                                     Lang.bind(this, this._onDragEnd));
        this._dragMonitor = {
            dragMotion: Lang.bind(this, this._onDragMotion)
        };

        this._dndTimeoutId = 0;
        this._dndWindow = null;

        this._settings = Convenience.getSettings();
        this._groupingModeChangedId =
            this._settings.connect('changed::grouping-mode',
                                   Lang.bind(this, this._groupingModeChanged));
        this._groupingModeChanged();
    },

    _groupingModeChanged: function() {
        this._groupingMode = this._settings.get_enum('grouping-mode');
        this._grouped = this._groupingMode == GroupingMode.ALWAYS;
        this._populateWindowList();
    },

    _populateWindowList: function() {
        this._windowList.destroy_all_children();

        if (!this._grouped) {
            let windows = Meta.get_window_actors(global.screen);
            for (let i = 0; i < windows.length; i++)
                this._onWindowAdded(null, windows[i].metaWindow);
        } else {
            let apps = this._appSystem.get_running();
            for (let i = 0; i < apps.length; i++)
                this._addApp(apps[i]);
        }
    },

    _updatePosition: function() {
        let monitor = Main.layoutManager.primaryMonitor;
        this.actor.width = monitor.width;
        this.actor.set_position(monitor.x, monitor.y + monitor.height - this.actor.height);
    },

    _updateKeyboardAnchor: function() {
        if (!Main.keyboard.actor)
            return;

        let anchorY = Main.overview.visible ? 0 : this.actor.height;
        Main.keyboard.actor.anchor_y = anchorY;
    },

    _updateMessageTrayAnchor: function() {
        let anchorY = this.actor.visible ? this.actor.height : 0;

        Main.messageTray.actor.anchor_y = anchorY;
        Main.messageTray._notificationWidget.anchor_y = -anchorY;
    },

    _onAppStateChanged: function(appSys, app) {
        if (!this._grouped)
            return;

        if (app.state == Shell.AppState.RUNNING)
            this._addApp(app);
        else if (app.state == Shell.AppState.STOPPED)
            this._removeApp(app);
    },

    _addApp: function(app) {
        let button = new AppButton(app);
        this._windowList.layout_manager.pack(button.actor,
                                             true, true, true,
                                             Clutter.BoxAlignment.START,
                                             Clutter.BoxAlignment.START);
    },

    _removeApp: function(app) {
        let children = this._windowList.get_children();
        for (let i = 0; i < children.length; i++) {
            if (children[i]._delegate.app == app) {
                children[i].destroy();
                return;
            }
        }
    },

    _onWindowAdded: function(ws, win) {
        if (!Shell.WindowTracker.get_default().is_window_interesting(win))
            return;

        if (this._grouped)
            return;

        let button = new WindowButton(win);
        this._windowList.layout_manager.pack(button.actor,
                                             true, true, true,
                                             Clutter.BoxAlignment.START,
                                             Clutter.BoxAlignment.START);
    },

    _onWindowRemoved: function(ws, win) {
        if (this._grouped) {
            if (this._groupingMode == GroupingMode.AUTO) {
                this._grouped = false;
                this._populateWindowList();
            }

            return;
        }

        let children = this._windowList.get_children();
        for (let i = 0; i < children.length; i++) {
            if (children[i]._delegate.metaWindow == win) {
                children[i].destroy();
                return;
            }
        }
    },

    _onWorkspacesChanged: function() {
        let numWorkspaces = global.screen.n_workspaces;
        for (let i = 0; i < numWorkspaces; i++) {
            let workspace = global.screen.get_workspace_by_index(i);
            if (this._workspaceSignals.has(workspace))
                continue;

            let signals = { windowAddedId: 0, windowRemovedId: 0 };
            signals._windowAddedId =
                workspace.connect_after('window-added',
                                        Lang.bind(this, this._onWindowAdded));
            signals._windowRemovedId =
                workspace.connect('window-removed',
                                  Lang.bind(this, this._onWindowRemoved));
            this._workspaceSignals.set(workspace, signals);
        }
    },

    _disconnectWorkspaceSignals: function() {
        let numWorkspaces = global.screen.n_workspaces;
        for (let i = 0; i < numWorkspaces; i++) {
            let workspace = global.screen.get_workspace_by_index(i);
            let signals = this._workspaceSignals.delete(workspace)[1];
            workspace.disconnect(signals._windowAddedId);
            workspace.disconnect(signals._windowRemovedId);
        }
    },

    _onDragBegin: function() {
        DND.addDragMonitor(this._dragMonitor);
    },

    _onDragEnd: function() {
        DND.removeDragMonitor(this._dragMonitor);
        this._removeActivateTimeout();
    },

    _onDragMotion: function(dragEvent) {
        if (Main.overview.visible ||
            !this.actor.contains(dragEvent.targetActor)) {
            this._removeActivateTimeout();
            return DND.DragMotionResult.CONTINUE;
        }

        let hoveredWindow = null;
        if (dragEvent.targetActor._delegate)
            hoveredWindow = dragEvent.targetActor._delegate.metaWindow;

        if (!hoveredWindow ||
            this._dndWindow == hoveredWindow)
            return DND.DragMotionResult.CONTINUE;

        this._removeActivateTimeout();

        this._dndWindow = hoveredWindow;
        this._dndTimeoutId = GLib.timeout_add(GLib.PRIORITY_DEFAULT,
                                              DND_ACTIVATE_TIMEOUT,
                                              Lang.bind(this, this._activateWindow));

        return DND.DragMotionResult.CONTINUE;
    },

    _removeActivateTimeout: function() {
        if (this._dndTimeoutId)
            GLib.source_remove (this._dndTimeoutId);
        this._dndTimeoutId = 0;
        this._dndWindow = null;
    },

    _activateWindow: function() {
        let [x, y] = global.get_pointer();
        let pickedActor = global.stage.get_actor_at_pos(Clutter.PickMode.ALL, x, y);

        if (this._dndWindow && this.actor.contains(pickedActor))
            this._dndWindow.activate(global.get_current_time());
        this._dndWindow = null;
        this._dndTimeoutId = 0;

        return false;
    },

    _onDestroy: function() {
        this._workspaceIndicator.destroy();

        Main.ctrlAltTabManager.removeGroup(this.actor);

        this._appSystem.disconnect(this._appStateChangedId);
        this._appStateChangedId = 0;

        Main.layoutManager.disconnect(this._monitorsChangedId);
        this._monitorsChangedId = 0;

        Main.layoutManager.disconnect(this._keyboardVisiblechangedId);
        this._keyboardVisiblechangedId = 0;

        Main.layoutManager.hideKeyboard();

        this._disconnectWorkspaceSignals();
        global.screen.disconnect(this._nWorkspacesChangedId);
        this._nWorkspacesChangedId = 0;

        Main.messageTray.actor.anchor_y = 0;
        Main.messageTray._notificationWidget.anchor_y = 0;

        Main.overview.disconnect(this._overviewShowingId);
        Main.overview.disconnect(this._overviewHidingId);

        global.screen.disconnect(this._fullscreenChangedId);

        this._settings.disconnect(this._groupingModeChangedId);

        let windows = Meta.get_window_actors(global.screen);
        for (let i = 0; i < windows.length; i++)
            windows[i].metaWindow.set_icon_geometry(null);
    }
});

let windowList;
let injections = {};
let notificationParent;

function init() {
}

function enable() {
    windowList = new WindowList();

    windowList.actor.connect('notify::hover', Lang.bind(Main.messageTray,
        function() {
            this._pointerInTray = windowList.actor.hover;
            this._updateState();
        }));

    injections['_trayDwellTimeout'] = MessageTray.MessageTray.prototype._trayDwellTimeout;
    MessageTray.MessageTray.prototype._trayDwellTimeout = function() {
        return false;
    };

    notificationParent = Main.messageTray._notificationWidget.get_parent();
    Main.messageTray._notificationWidget.hide();
    Main.messageTray._notificationWidget.reparent(windowList.actor);
    Main.messageTray._notificationWidget.show();
}

function disable() {
    var prop;

    if (!windowList)
        return;

    windowList.actor.hide();

    if (notificationParent) {
        Main.messageTray._notificationWidget.reparent(notificationParent);
        notificationParent = null;
    }

    windowList.actor.destroy();
    windowList = null;

    for (prop in injections)
        MessageTray.MessageTray.prototype[prop] = injections[prop];
}
