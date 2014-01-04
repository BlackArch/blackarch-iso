/* -*- mode: js2; js2-basic-offset: 4; indent-tabs-mode: nil -*- */

const Gio = imports.gi.Gio;
const Gtk = imports.gi.Gtk;
const GObject = imports.gi.GObject;
const Lang = imports.lang;

const Gettext = imports.gettext.domain('gnome-shell-extensions');
const _ = Gettext.gettext;
const N_ = function(e) { return e };

const ExtensionUtils = imports.misc.extensionUtils;
const Me = ExtensionUtils.getCurrentExtension();
const Convenience = Me.imports.convenience;

const SETTINGS_APP_ICON_MODE = 'app-icon-mode';
const SETTINGS_CURRENT_WORKSPACE_ONLY = 'current-workspace-only';

const MODES = {
    'thumbnail-only': N_("Thumbnail only"),
    'app-icon-only': N_("Application icon only"),
    'both': N_("Thumbnail and application icon"),
};

const AltTabSettingsWidget = new GObject.Class({
    Name: 'AlternateTab.Prefs.AltTabSettingsWidget',
    GTypeName: 'AltTabSettingsWidget',
    Extends: Gtk.Grid,

    _init : function(params) {
        this.parent(params);
        this.margin = 10;
	this.orientation = Gtk.Orientation.VERTICAL;

        this._settings = new Gio.Settings({ schema: 'org.gnome.shell.window-switcher' });

        let presentLabel = _("Present windows as");
        this.add(new Gtk.Label({ label: presentLabel, sensitive: true,
                                 margin_bottom: 10, margin_top: 5 }));

        let top = 1;
        let radio = null;
        let currentMode = this._settings.get_string(SETTINGS_APP_ICON_MODE);
        for (let mode in MODES) {
            // copy the mode variable because it has function scope, not block scope
            // so cannot be used in a closure
            let modeCapture = mode;
            let name = Gettext.gettext(MODES[mode]);

            radio = new Gtk.RadioButton({ group: radio, label: name, valign: Gtk.Align.START });
            radio.connect('toggled', Lang.bind(this, function(widget) {
                if (widget.active)
                    this._settings.set_string(SETTINGS_APP_ICON_MODE, modeCapture);
            }));
            this.add(radio);

            if (mode == currentMode)
                radio.active = true;
            top += 1;
        }

	let check = new Gtk.CheckButton({ label: _("Show only windows in the current workspace"),
					  margin_top: 12 });
	this._settings.bind(SETTINGS_CURRENT_WORKSPACE_ONLY, check, 'active', Gio.SettingsBindFlags.DEFAULT);
	this.add(check);
    },
});

function init() {
    Convenience.initTranslations();
}

function buildPrefsWidget() {
    let widget = new AltTabSettingsWidget();
    widget.show_all();

    return widget;
}
