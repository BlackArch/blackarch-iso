// -*- mode: js2; indent-tabs-mode: nil; js2-basic-offset: 4 -*-
// Start apps on custom workspaces

const Glib = imports.gi.GLib;
const Gio = imports.gi.Gio;
const Lang = imports.lang;
const Mainloop = imports.mainloop;
const Meta = imports.gi.Meta;
const Shell = imports.gi.Shell;
const St = imports.gi.St;

const Main = imports.ui.main;

const ExtensionUtils = imports.misc.extensionUtils;
const Me = ExtensionUtils.getCurrentExtension();
const Convenience = Me.imports.convenience;

const SETTINGS_KEY = 'application-list';

let settings;

const WindowMover = new Lang.Class({
    Name: 'AutoMoveWindows.WindowMover',

    _init: function() {
        this._settings = settings;
        this._windowTracker = Shell.WindowTracker.get_default();

        let display = global.screen.get_display();
        // Connect after so the handler from ShellWindowTracker has already run
        this._windowCreatedId = display.connect_after('window-created', Lang.bind(this, this._findAndMove));
    },

    destroy: function() {
        if (this._windowCreatedId) {
            global.screen.get_display().disconnect(this._windowCreatedId);
            this._windowCreatedId = 0;
        }
    },

    _ensureAtLeastWorkspaces: function(num, window) {
        for (let j = global.screen.n_workspaces; j <= num; j++) {
            window.change_workspace_by_index(j-1, false, global.get_current_time());
            global.screen.append_new_workspace(false, 0);
        }
    },

    _findAndMove: function(display, window, noRecurse) {
        if (!this._windowTracker.is_window_interesting(window))
            return;

        let spaces = this._settings.get_strv(SETTINGS_KEY);

        let app = this._windowTracker.get_window_app(window);
        if (!app) {
            if (!noRecurse) {
                // window is not tracked yet
                Mainloop.idle_add(Lang.bind(this, function() {
                    this._findAndMove(display, window, true);
                    return false;
                }));
            } else
                log ('Cannot find application for window');
            return;
        }
        let app_id = app.get_id();
        for ( let j = 0 ; j < spaces.length; j++ ) {
            let apps_to_space = spaces[j].split(":");
            // Match application id
            if (apps_to_space[0] == app_id) {
                let workspace_num = parseInt(apps_to_space[1]) - 1;

                if (workspace_num >= global.screen.n_workspaces)
                    this._ensureAtLeastWorkspaces(workspace_num, window);

                window.change_workspace_by_index(workspace_num, false, global.get_current_time());
            }
        }
    }
});

let prevCheckWorkspaces;
let winMover;

function init() {
    Convenience.initTranslations();
    settings = Convenience.getSettings();
}

function myCheckWorkspaces() {
    let i;
    let emptyWorkspaces = new Array(this._workspaces.length);

    for (i = 0; i < this._workspaces.length; i++) {
	let lastRemoved = this._workspaces[i]._lastRemovedWindow;
	if (lastRemoved &&
            (lastRemoved.get_window_type() == Meta.WindowType.SPLASHSCREEN ||
             lastRemoved.get_window_type() == Meta.WindowType.DIALOG ||
             lastRemoved.get_window_type() == Meta.WindowType.MODAL_DIALOG))
            emptyWorkspaces[i] = false;
	else
            emptyWorkspaces[i] = true;
    }

    let windows = global.get_window_actors();
    for (i = 0; i < windows.length; i++) {
	let win = windows[i];

	if (win.get_meta_window().is_on_all_workspaces())
            continue;

	let workspaceIndex = win.get_workspace();
	emptyWorkspaces[workspaceIndex] = false;
    }

    // If we don't have an empty workspace at the end, add one
    if (!emptyWorkspaces[emptyWorkspaces.length -1]) {
	global.screen.append_new_workspace(false, global.get_current_time());
	emptyWorkspaces.push(false);
    }

    let activeWorkspaceIndex = global.screen.get_active_workspace_index();
    let activeIsLast = activeWorkspaceIndex == global.screen.n_workspaces - 2;
    let removingTrailWorkspaces = (emptyWorkspaces[activeWorkspaceIndex] &&
                                   activeIsLast);
    // Don't enter the overview when removing multiple empty workspaces at startup
    let showOverview  = (removingTrailWorkspaces &&
                         !emptyWorkspaces.every(function(x) { return x; }));

    if (removingTrailWorkspaces) {
        // "Merge" the empty workspace we are removing with the one at the end
        this._wm.blockAnimations();
    }

    // Delete other empty workspaces; do it from the end to avoid index changes
    for (i = emptyWorkspaces.length - 2; i >= 0; i--) {
        if (emptyWorkspaces[i])
            global.screen.remove_workspace(this._workspaces[i], global.get_current_time());
        else
            break;
    }

    if (removingTrailWorkspaces) {
        global.screen.get_workspace_by_index(global.screen.n_workspaces - 1).activate(global.get_current_time());

        this._wm.unblockAnimations();

        if (!Main.overview.visible && showOverview)
            Main.overview.show();
    }

    this._checkWorkspacesId = 0;
    return false;
}

function enable() {
    prevCheckWorkspaces = Main.wm._workspaceTracker._checkWorkspaces;
    if (Meta.prefs_get_dynamic_workspaces())
	Main.wm._workspaceTracker._checkWorkspaces = myCheckWorkspaces;

    winMover = new WindowMover();
}

function disable() {
    Main.wm._workspaceTracker._checkWorkspaces = prevCheckWorkspaces;
    winMover.destroy();
}
