const Main = imports.ui.main;
const AppDisplay = imports.ui.appDisplay;

var _onActivateOriginal = null;
var _activateResultOriginal = null;

function _onActivate(event) {

  this.emit('launching');

  if (this._onActivateOverride) {
    this._onActivateOverride(event);
  } else {
    this.app.open_new_window(-1);
  }
  Main.overview.hide();
}

function _activateResult(app) {
  app.open_new_window(-1);
}

function init() {
}

function enable() {
  _onActivateOriginal = AppDisplay.AppIcon.prototype._onActivate;
  AppDisplay.AppIcon.prototype._onActivate = _onActivate;

  _activateResultOriginal = AppDisplay.AppSearchProvider.prototype.activateResult;
  AppDisplay.AppSearchProvider.prototype.activateResult = _activateResult;
}

function disable() {
  AppDisplay.AppIcon.prototype._onActivate = _onActivateOriginal;
  AppDisplay.AppSearchProvider.prototype.activateResult = _activateResultOriginal;
}
