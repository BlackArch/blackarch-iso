// -*- mode: js2; indent-tabs-mode: nil; js2-basic-offset: 4 -*-

const Gio = imports.gi.Gio;
const Meta = imports.gi.Meta;
const Clutter = imports.gi.Clutter;
const St = imports.gi.St;
const Lang = imports.lang;
const Mainloop = imports.mainloop;
const PanelMenu = imports.ui.panelMenu;
const PopupMenu = imports.ui.popupMenu;
const Panel = imports.ui.panel;

const Gettext = imports.gettext.domain('gnome-shell-extensions');
const _ = Gettext.gettext;

const Main = imports.ui.main;

const ExtensionUtils = imports.misc.extensionUtils;
const Me = ExtensionUtils.getCurrentExtension();
const Convenience = Me.imports.convenience;

const WORKSPACE_SCHEMA = 'org.gnome.desktop.wm.preferences';
const WORKSPACE_KEY = 'workspace-names';

const WorkspaceIndicator = new Lang.Class({
    Name: 'WorkspaceIndicator.WorkspaceIndicator',
    Extends: PanelMenu.Button,

    _init: function(){
	this.parent(0.0, _("Workspace Indicator"));

	this._currentWorkspace = global.screen.get_active_workspace().index();
	this.statusLabel = new St.Label({ text: this._labelText() });

	this.actor.add_actor(this.statusLabel);

	this.workspacesItems = [];
	this._workspaceSection = new PopupMenu.PopupMenuSection();
	this.menu.addMenuItem(this._workspaceSection);

	this._screenSignals = [];
	this._screenSignals.push(global.screen.connect_after('workspace-added', Lang.bind(this,this._createWorkspacesSection)));
	this._screenSignals.push(global.screen.connect_after('workspace-removed', Lang.bind(this,this._createWorkspacesSection)));
	this._screenSignals.push(global.screen.connect_after('workspace-switched', Lang.bind(this,this._updateIndicator)));

	this.actor.connect('scroll-event', Lang.bind(this, this._onScrollEvent));
	this._createWorkspacesSection();

	//styling
	this.statusLabel.add_style_class_name('panel-workspace-indicator');

        this._settings = new Gio.Settings({ schema: WORKSPACE_SCHEMA });
        this._settingsChangedId = this._settings.connect('changed::' + WORKSPACE_KEY, Lang.bind(this, this._createWorkspacesSection));
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

	this.statusLabel.set_text(this._labelText());
    },

    _labelText : function(workspaceIndex) {
	if(workspaceIndex == undefined) {
	    workspaceIndex = this._currentWorkspace;
	    return (workspaceIndex + 1).toString();
	}
	return Meta.prefs_get_workspace_name(workspaceIndex);
    },

    _createWorkspacesSection : function() {
	this._workspaceSection.removeAll();
	this.workspacesItems = [];
	this._currentWorkspace = global.screen.get_active_workspace().index();

	let i = 0;
	for(; i < global.screen.n_workspaces; i++) {
	    this.workspacesItems[i] = new PopupMenu.PopupMenuItem(this._labelText(i));
	    this._workspaceSection.addMenuItem(this.workspacesItems[i]);
	    this.workspacesItems[i].workspaceId = i;
	    this.workspacesItems[i].label_actor = this.statusLabel;
	    let self = this;
	    this.workspacesItems[i].connect('activate', Lang.bind(this, function(actor, event) {
		this._activate(actor.workspaceId);
	    }));

	    if (i == this._currentWorkspace)
		this.workspacesItems[i].setOrnament(PopupMenu.Ornament.DOT);
	}

	this.statusLabel.set_text(this._labelText());
    },

    _activate : function (index) {
	if(index >= 0 && index <  global.screen.n_workspaces) {
	    let metaWorkspace = global.screen.get_workspace_by_index(index);
	    metaWorkspace.activate(global.get_current_time());
	}
    },

    _onScrollEvent : function(actor, event) {
	let direction = event.get_scroll_direction();
	let diff = 0;
	if (direction == Clutter.ScrollDirection.DOWN) {
	    diff = 1;
	} else if (direction == Clutter.ScrollDirection.UP) {
	    diff = -1;
	} else {
	    return;
	}

	let newIndex = global.screen.get_active_workspace().index() + diff;
	this._activate(newIndex);
    },
});

function init(meta) {
    Convenience.initTranslations();
}

let _indicator;

function enable() {
    _indicator = new WorkspaceIndicator;
    Main.panel.addToStatusArea('workspace-indicator', _indicator);
}

function disable() {
    _indicator.destroy();
}
