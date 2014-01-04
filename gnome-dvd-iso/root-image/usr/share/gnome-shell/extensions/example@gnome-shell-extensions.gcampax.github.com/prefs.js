// -*- mode: js2; indent-tabs-mode: nil; js2-basic-offset: 4 -*-

const GLib = imports.gi.GLib;
const GObject = imports.gi.GObject;
const Gio = imports.gi.Gio;
const Gtk = imports.gi.Gtk;

const Gettext = imports.gettext.domain('gnome-shell-extensions');
const _ = Gettext.gettext;

const ExtensionUtils = imports.misc.extensionUtils;
const Me = ExtensionUtils.getCurrentExtension();
const Convenience = Me.imports.convenience;

function init() {
    Convenience.initTranslations();
}

const ExamplePrefsWidget = new GObject.Class({
    Name: 'Example.Prefs.Widget',
    GTypeName: 'ExamplePrefsWidget',
    Extends: Gtk.Grid,

    _init: function(params) {
	this.parent(params);
        this.margin = this.row_spacing = this.column_spacing = 10;

	// TRANSLATORS: Example is the name of the extension, should not be
	// translated
	let primaryText = _("Example aims to show how to build well behaved \
extensions for the Shell and as such it has little functionality on its own.\n\
Nevertheless it's possible to customize the greeting message.");

	this.attach(new Gtk.Label({ label: primaryText, wrap: true }), 0, 0, 2, 1);

	this.attach(new Gtk.Label({ label: '<b>' + _("Message:") + '</b>', use_markup: true }),
		    0, 1, 1, 1);

	let entry = new Gtk.Entry({ hexpand: true });
	this.attach(entry, 1, 1, 1, 1);

	this._settings = Convenience.getSettings();
	this._settings.bind('hello-text', entry, 'text', Gio.SettingsBindFlags.DEFAULT);
    }
});

function buildPrefsWidget() {
    let widget = new ExamplePrefsWidget();
    widget.show_all();

    return widget;
}
