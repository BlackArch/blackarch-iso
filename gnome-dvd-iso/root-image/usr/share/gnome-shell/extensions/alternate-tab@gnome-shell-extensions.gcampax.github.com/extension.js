/* -*- mode: js; js-basic-offset: 4; indent-tabs-mode: nil -*- */

const Clutter = imports.gi.Clutter;
const Lang = imports.lang;
const Meta = imports.gi.Meta;
const Shell = imports.gi.Shell;

const AltTab = imports.ui.altTab;
const Main = imports.ui.main;

let injections = {};

function init(metadata) {
}

function setKeybinding(name, func) {
    Main.wm.setCustomKeybindingHandler(name, Shell.KeyBindingMode.NORMAL, func);
}

function enable() {
    injections['_initialSelection'] = AltTab.WindowSwitcherPopup.prototype._initialSelection;
    AltTab.WindowSwitcherPopup.prototype._initialSelection = function(backward, binding) {
        if (binding == 'switch-windows-backward' ||
            binding == 'switch-applications-backward' ||
            binding == 'switch-group-backward' || backward)
            this._select(this._items.length - 1);
        else if (this._items.length == 1)
            this._select(0);
        else
            this._select(1);
    };
    injections['_keyPressHandler'] = AltTab.WindowSwitcherPopup.prototype._keyPressHandler;
    AltTab.WindowSwitcherPopup.prototype._keyPressHandler = function(keysym, backwards, action) {
        if (action == Meta.KeyBindingAction.SWITCH_WINDOWS ||
            action == Meta.KeyBindingAction.SWITCH_APPLICATIONS ||
            action == Meta.KeyBindingAction.SWITCH_GROUP) {
            this._select(backwards ? this._previous() : this._next());
        } else if (action == Meta.KeyBindingAction.SWITCH_WINDOWS_BACKWARD ||
                   action == Meta.KeyBindingAction.SWITCH_APPLICATIONS_BACKWARD ||
                   action == Meta.KeyBindingAction.SWITCH_GROUP_BACKWARD) {
            this._select(this._previous());
        } else {
            if (keysym == Clutter.Left)
                this._select(this._previous());
            else if (keysym == Clutter.Right)
                this._select(this._next());
        }
    };

    setKeybinding('switch-applications', Lang.bind(Main.wm, Main.wm._startWindowSwitcher));
    setKeybinding('switch-group', Lang.bind(Main.wm, Main.wm._startWindowSwitcher));
    setKeybinding('switch-applications-backward', Lang.bind(Main.wm, Main.wm._startWindowSwitcher));
    setKeybinding('switch-group-backward', Lang.bind(Main.wm, Main.wm._startWindowSwitcher));
}

function disable() {
    var prop;

    setKeybinding('switch-applications', Lang.bind(Main.wm, Main.wm._startAppSwitcher));
    setKeybinding('switch-group', Lang.bind(Main.wm, Main.wm._startAppSwitcher));
    setKeybinding('switch-applications-backward', Lang.bind(Main.wm, Main.wm._startAppSwitcher));
    setKeybinding('switch-group-backward', Lang.bind(Main.wm, Main.wm._startAppSwitcher));

    for (prop in injections)
        AltTab.WindowSwitcherPopup.prototype[prop] = injections[prop];
}
