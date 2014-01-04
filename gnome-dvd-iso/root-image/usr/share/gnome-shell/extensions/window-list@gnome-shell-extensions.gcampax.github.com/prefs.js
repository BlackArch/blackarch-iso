// -*- mode: js2; indent-tabs-mode: nil; js2-basic-offset: 4 -*-

const GObject = imports.gi.GObject;
const Gtk = imports.gi.Gtk;
const Lang = imports.lang;

const Gettext = imports.gettext.domain('gnome-shell-extensions');
const _ = Gettext.gettext;

const ExtensionUtils = imports.misc.extensionUtils;
const Me = ExtensionUtils.getCurrentExtension();
const Convenience = Me.imports.convenience;


function init() {
    Convenience.initTranslations();
}

const WindowListPrefsWidget = new GObject.Class({
    Name: 'WindowList.Prefs.Widget',
    GTypeName: 'WindowListPrefsWidget',
    Extends: Gtk.Frame,

    _init: function(params) {
        this.parent(params);

        this.shadow_type = Gtk.ShadowType.NONE;
        this.margin = 24;

        let title = '<b>' + _("Window Grouping") + '</b>';
        let titleLabel = new Gtk.Label({ use_markup: true, label: title });
        this.set_label_widget(titleLabel);

        let align = new Gtk.Alignment({ left_padding: 12 });
        this.add(align);

        let grid = new Gtk.Grid({ orientation: Gtk.Orientation.VERTICAL,
                                  row_spacing: 6,
                                  column_spacing: 6,
                                  margin_top: 6 });
        align.add(grid);

        this._settings = Convenience.getSettings();
        let currentMode = this._settings.get_string('grouping-mode');
        let range = this._settings.get_range('grouping-mode');
        let modes = range.deep_unpack()[1].deep_unpack();

        let modeLabels = {
            'never': _("Never group windows"),
            'auto': _("Group windows when space is limited"),
            'always': _("Always group windows")
        };

        let radio = null;
        for (let i = 0; i < modes.length; i++) {
            let mode = modes[i];
            let label = modeLabels[mode];
            if (!label) {
               log('Unhandled option "%s" for grouping-mode'.format(mode));
               continue;
            }

            radio = new Gtk.RadioButton({ active: currentMode == mode,
                                          label: label,
                                          group: radio });
            grid.add(radio);

            radio.connect('toggled', Lang.bind(this, function(button) {
                if (button.active)
                    this._settings.set_string('grouping-mode', mode);
            }));
        }
    }
});

function buildPrefsWidget() {
    let widget = new WindowListPrefsWidget();
    widget.show_all();

    return widget;
}
