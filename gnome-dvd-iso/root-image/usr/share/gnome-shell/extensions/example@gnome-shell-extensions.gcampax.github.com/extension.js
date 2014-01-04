// -*- mode: js2; indent-tabs-mode: nil; js2-basic-offset: 4 -*-
// Sample extension code, makes clicking on the panel show a message
const St = imports.gi.St;
const Mainloop = imports.mainloop;

const Gettext = imports.gettext.domain('gnome-shell-extensions');
const _ = Gettext.gettext;

const Main = imports.ui.main;

const ExtensionUtils = imports.misc.extensionUtils;
const Me = ExtensionUtils.getCurrentExtension();
const Convenience = Me.imports.convenience;

function _showHello() {
    let settings = Convenience.getSettings();
    let text = settings.get_string('hello-text') || _("Hello, world!");

    let label = new St.Label({ style_class: 'helloworld-label', text: text });
    let monitor = Main.layoutManager.primaryMonitor;
    global.stage.add_actor(label);
    label.set_position(Math.floor (monitor.width / 2 - label.width / 2), Math.floor(monitor.height / 2 - label.height / 2));
    Mainloop.timeout_add(3000, function () { label.destroy(); });
}

// Put your extension initialization code here
function init(metadata) {
    log ('Example extension initalized');

    Convenience.initTranslations();
}

let signalId;

function enable() {
    log ('Example extension enabled');

    Main.panel.actor.reactive = true;
    signalId = Main.panel.actor.connect('button-release-event', _showHello);
}

function disable() {
    log ('Example extension disabled');

    if (signalId) {
	Main.panel.actor.disconnect(signalId);
	signalId = 0;
    }
}
