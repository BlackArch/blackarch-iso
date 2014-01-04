// -*- mode: js2; indent-tabs-mode: nil; js2-basic-offset: 4 -*-
// Start apps on custom workspaces

const GdkPixbuf = imports.gi.GdkPixbuf;
const Gio = imports.gi.Gio;
const GLib = imports.gi.GLib;
const GObject = imports.gi.GObject;
const GMenu = imports.gi.GMenu;
const Gtk = imports.gi.Gtk;
const Lang = imports.lang;
const Mainloop = imports.mainloop;

const Gettext = imports.gettext.domain('gnome-shell-extensions');
const _ = Gettext.gettext;
const N_ = function(e) { return e };

const ExtensionUtils = imports.misc.extensionUtils;
const Me = ExtensionUtils.getCurrentExtension();
const Convenience = Me.imports.convenience;

const SETTINGS_KEY = 'application-list';

const WORKSPACE_MAX = 36; // compiled in limit of mutter

const Columns = {
    APPINFO: 0,
    DISPLAY_NAME: 1,
    ICON: 2,
    WORKSPACE: 3,
    ADJUSTMENT: 4
};

const Widget = new GObject.Class({
    Name: 'AutoMoveWindows.Prefs.Widget',
    GTypeName: 'AutoMoveWindowsPrefsWidget',
    Extends: Gtk.Grid,

    _init: function(params) {
	this.parent(params);
	this.set_orientation(Gtk.Orientation.VERTICAL);

	this._settings = Convenience.getSettings();
	this._settings.connect('changed', Lang.bind(this, this._refresh));
	this._changedPermitted = false;

	this._store = new Gtk.ListStore();
	this._store.set_column_types([Gio.AppInfo, GObject.TYPE_STRING, Gio.Icon, GObject.TYPE_INT,
                                      Gtk.Adjustment]);

	this._treeView = new Gtk.TreeView({ model: this._store,
                                            hexpand: true, vexpand: true });
	this._treeView.get_selection().set_mode(Gtk.SelectionMode.SINGLE);

	let appColumn = new Gtk.TreeViewColumn({ expand: true, sort_column_id: Columns.DISPLAY_NAME,
						 title: _("Application") });
	let iconRenderer = new Gtk.CellRendererPixbuf;
	appColumn.pack_start(iconRenderer, false);
	appColumn.add_attribute(iconRenderer, "gicon", Columns.ICON);
	let nameRenderer = new Gtk.CellRendererText;
	appColumn.pack_start(nameRenderer, true);
	appColumn.add_attribute(nameRenderer, "text", Columns.DISPLAY_NAME);
	this._treeView.append_column(appColumn);

	let workspaceColumn = new Gtk.TreeViewColumn({ title: _("Workspace"),
                                                       sort_column_id: Columns.WORKSPACE });
	let workspaceRenderer = new Gtk.CellRendererSpin({ editable: true });
	workspaceRenderer.connect('edited', Lang.bind(this, this._workspaceEdited));
	workspaceColumn.pack_start(workspaceRenderer, true);
	workspaceColumn.add_attribute(workspaceRenderer, "adjustment", Columns.ADJUSTMENT);
        workspaceColumn.add_attribute(workspaceRenderer, "text", Columns.WORKSPACE);
	this._treeView.append_column(workspaceColumn);

	this.add(this._treeView);

	let toolbar = new Gtk.Toolbar();
	toolbar.get_style_context().add_class(Gtk.STYLE_CLASS_INLINE_TOOLBAR);
	this.add(toolbar);

	let newButton = new Gtk.ToolButton({ stock_id: Gtk.STOCK_NEW,
                                             label: _("Add rule"),
					     is_important: true });
	newButton.connect('clicked', Lang.bind(this, this._createNew));
	toolbar.add(newButton);

	let delButton = new Gtk.ToolButton({ stock_id: Gtk.STOCK_DELETE });
	delButton.connect('clicked', Lang.bind(this, this._deleteSelected));
	toolbar.add(delButton);

	this._changedPermitted = true;
	this._refresh();
    },

    _createNew: function() {
	let dialog = new Gtk.Dialog({ title: _("Create new matching rule"),
				      transient_for: this.get_toplevel(),
				      modal: true });
	dialog.add_button(Gtk.STOCK_CANCEL, Gtk.ResponseType.CANCEL);
	dialog.add_button(_("Add"), Gtk.ResponseType.OK);
        dialog.set_default_response(Gtk.ResponseType.OK);

	let grid = new Gtk.Grid({ column_spacing: 10,
                                  row_spacing: 15,
                                  margin: 10 });
	dialog._appChooser = new Gtk.AppChooserWidget({ show_all: true });
	grid.attach(dialog._appChooser, 0, 0, 2, 1);
	grid.attach(new Gtk.Label({ label: _("Workspace") }),
		    0, 1, 1, 1);
	let adjustment = new Gtk.Adjustment({ lower: 1,
					      upper: WORKSPACE_MAX,
					      step_increment: 1
                                            });
	dialog._spin = new Gtk.SpinButton({ adjustment: adjustment,
					    snap_to_ticks: true });
        dialog._spin.set_value(1);
	grid.attach(dialog._spin, 1, 1, 1, 1);
	dialog.get_content_area().add(grid);

	dialog.connect('response', Lang.bind(this, function(dialog, id) {
	    if (id != Gtk.ResponseType.OK) {
                dialog.destroy();
		return;
            }

	    let appInfo = dialog._appChooser.get_app_info();
	    if (!appInfo)
		return;
	    let index = Math.floor(dialog._spin.value);
	    if (isNaN(index) || index < 0)
		index = 1;

	    this._changedPermitted = false;
	    if (!this._appendItem(appInfo.get_id(), index)) {
                this._changedPermitted = true;
                return;
            }
	    let iter = this._store.append();
	    let adj = new Gtk.Adjustment({ lower: 1,
					   upper: WORKSPACE_MAX,
					   step_increment: 1,
                                           value: index });
	    this._store.set(iter,
			    [Columns.APPINFO, Columns.ICON, Columns.DISPLAY_NAME, Columns.WORKSPACE, Columns.ADJUSTMENT],
			    [appInfo, appInfo.get_icon(), appInfo.get_display_name(), index, adj]);
	    this._changedPermitted = true;

            dialog.destroy();
	}));
	dialog.show_all();
    },

    _deleteSelected: function() {
	let [any, model, iter] = this._treeView.get_selection().get_selected();

	if (any) {
	    let appInfo = this._store.get_value(iter, Columns.APPINFO);

	    this._changedPermitted = false;
	    this._removeItem(appInfo.get_id());
	    this._store.remove(iter);
	    this._changedPermitted = true;
	}
    },

    _workspaceEdited: function(renderer, pathString, text) {
	let index = parseInt(text);
	if (isNaN(index) || index < 0)
	    index = 1;
        let path = Gtk.TreePath.new_from_string(pathString);
	let [model, iter] = this._store.get_iter(path);
	let appInfo = this._store.get_value(iter, Columns.APPINFO);

	this._changedPermitted = false;
	this._changeItem(appInfo.get_id(), index);
	this._store.set_value(iter, Columns.WORKSPACE, index);
	this._changedPermitted = true;
    },

    _refresh: function() {
	if (!this._changedPermitted)
	    // Ignore this notification, model is being modified outside
	    return;

	this._store.clear();

	let currentItems = this._settings.get_strv(SETTINGS_KEY);
	let validItems = [ ];
	for (let i = 0; i < currentItems.length; i++) {
	    let [id, index] = currentItems[i].split(':');
	    let appInfo = Gio.DesktopAppInfo.new(id);
	    if (!appInfo)
		continue;
	    validItems.push(currentItems[i]);

	    let iter = this._store.append();
	    let adj = new Gtk.Adjustment({ lower: 1,
					   upper: WORKSPACE_MAX,
					   step_increment: 1,
                                           value: index });
	    this._store.set(iter,
			    [Columns.APPINFO, Columns.ICON, Columns.DISPLAY_NAME, Columns.WORKSPACE, Columns.ADJUSTMENT],
			    [appInfo, appInfo.get_icon(), appInfo.get_display_name(), parseInt(index), adj]);
	}

	if (validItems.length != currentItems.length) // some items were filtered out
	    this._settings.set_strv(SETTINGS_KEY, validItems);
    },

    _appendItem: function(id, workspace) {
	let currentItems = this._settings.get_strv(SETTINGS_KEY);
	let alreadyHave = currentItems.map(function(el) {
	    return el.split(':')[0];
	}).indexOf(id) != -1;

	if (alreadyHave) {
            printerr("Already have an item for this id");
	    return false;
        }

	currentItems.push(id + ':' + workspace);
	this._settings.set_strv(SETTINGS_KEY, currentItems);
        return true;
    },

    _removeItem: function(id) {
	let currentItems = this._settings.get_strv(SETTINGS_KEY);
	let index = currentItems.map(function(el) {
	    return el.split(':')[0];
	}).indexOf(id);

	if (index < 0)
	    return;
	currentItems.splice(index, 1);
	this._settings.set_strv(SETTINGS_KEY, currentItems);
    },

    _changeItem: function(id, workspace) {
	let currentItems = this._settings.get_strv(SETTINGS_KEY);
	let index = currentItems.map(function(el) {
	    return el.split(':')[0];
	}).indexOf(id);

	if (index < 0)
	    currentItems.push(id + ':' + workspace);
	else
	    currentItems[index] = id + ':' + workspace;
	this._settings.set_strv(SETTINGS_KEY, currentItems);
    }
});


function init() {
    Convenience.initTranslations();
}

function buildPrefsWidget() {
    let widget = new Widget();
    widget.show_all();

    return widget;
}
