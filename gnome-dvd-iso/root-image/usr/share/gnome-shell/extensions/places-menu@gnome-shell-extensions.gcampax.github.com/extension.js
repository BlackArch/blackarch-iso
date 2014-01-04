/* -*- mode: js2; js2-basic-offset: 4; indent-tabs-mode: nil -*- */

const Clutter = imports.gi.Clutter;
const Gio = imports.gi.Gio;
const GLib = imports.gi.GLib;
const Lang = imports.lang;
const Shell = imports.gi.Shell;
const St = imports.gi.St;

const Main = imports.ui.main;
const PanelMenu = imports.ui.panelMenu;
const PopupMenu = imports.ui.popupMenu;
const Panel = imports.ui.panel;

const Gettext = imports.gettext.domain('gnome-shell-extensions');
const _ = Gettext.gettext;
const N_ = function(x) { return x; }

const ExtensionUtils = imports.misc.extensionUtils;
const Me = ExtensionUtils.getCurrentExtension();
const Convenience = Me.imports.convenience;
const PlaceDisplay = Me.imports.placeDisplay;

const PLACE_ICON_SIZE = 16;

const PlaceMenuItem = new Lang.Class({
    Name: 'PlaceMenuItem',
    Extends: PopupMenu.PopupBaseMenuItem,

    _init: function(info) {
	this.parent();
	this._info = info;

        this._icon = new St.Icon({ gicon: info.icon,
                                   icon_size: PLACE_ICON_SIZE });
	this.actor.add_child(this._icon);

        this._label = new St.Label({ text: info.name });
        this.actor.add_child(this._label);

        this._changedId = info.connect('changed',
                                       Lang.bind(this, this._propertiesChanged));
    },

    destroy: function() {
        if (this._changedId) {
            this._info.disconnect(this._changedId);
            this._changedId = 0;
        }

        this.parent();
    },

    activate: function(event) {
	this._info.launch(event.get_time());

	this.parent(event);
    },

    _propertiesChanged: function(info) {
        this._icon.gicon = info.icon;
        this._label.text = info.name;
    },
});

const SECTIONS = [
    'special',
    'devices',
    'bookmarks',
    'network'
]

const PlacesMenu = new Lang.Class({
    Name: 'PlacesMenu.PlacesMenu',
    Extends: PanelMenu.Button,

    _init: function() {
        this.parent(0.0, _("Places"));

        let hbox = new St.BoxLayout({ style_class: 'panel-status-menu-box' });
        let label = new St.Label({ text: _("Places"),
                                   y_expand: true,
                                   y_align: Clutter.ActorAlign.CENTER });
        hbox.add_child(label);
        hbox.add_child(new St.Label({ text: '\u25BE',
                                      y_expand: true,
                                      y_align: Clutter.ActorAlign.CENTER }));
        this.actor.add_actor(hbox);

        this.placesManager = new PlaceDisplay.PlacesManager();

	this._sections = { };

	for (let i=0; i < SECTIONS.length; i++) {
	    let id = SECTIONS[i];
	    this._sections[id] = new PopupMenu.PopupMenuSection();
	    this.placesManager.connect(id + '-updated', Lang.bind(this, function() {
		this._redisplay(id);
	    }));

	    this._create(id);
	    this.menu.addMenuItem(this._sections[id]);
	    this.menu.addMenuItem(new PopupMenu.PopupSeparatorMenuItem());
	}
    },

    destroy: function() {
	this.placesManager.destroy();

        this.parent();
    },

    _redisplay: function(id) {
	this._sections[id].removeAll();
        this._create(id);
    },

    _create: function(id) {
        let places = this.placesManager.get(id);

        for (let i = 0; i < places.length; i++)
            this._sections[id].addMenuItem(new PlaceMenuItem(places[i]));

	this._sections[id].actor.visible = places.length > 0;
    }
});

function init() {
    Convenience.initTranslations();
}

let _indicator;

function enable() {
    _indicator = new PlacesMenu;

    let pos = 1;
    if ('apps-menu' in Main.panel.statusArea)
	pos = 2;
    Main.panel.addToStatusArea('places-menu', _indicator, pos, 'left');
}

function disable() {
    _indicator.destroy();
}
