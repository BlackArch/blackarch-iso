/* -*- mode: js2; js2-basic-offset: 4; indent-tabs-mode: nil -*- */

const Atk = imports.gi.Atk;
const GMenu = imports.gi.GMenu;
const Lang = imports.lang;
const Shell = imports.gi.Shell;
const St = imports.gi.St;
const Clutter = imports.gi.Clutter;
const Main = imports.ui.main;
const PanelMenu = imports.ui.panelMenu;
const PopupMenu = imports.ui.popupMenu;
const Gtk = imports.gi.Gtk;
const GLib = imports.gi.GLib;
const Signals = imports.signals;
const Layout = imports.ui.layout;
const Pango = imports.gi.Pango;

const Gettext = imports.gettext.domain('gnome-shell-extensions');
const _ = Gettext.gettext;

const ExtensionUtils = imports.misc.extensionUtils;
const Me = ExtensionUtils.getCurrentExtension();
const Convenience = Me.imports.convenience;

const appSys = Shell.AppSystem.get_default();

const APPLICATION_ICON_SIZE = 32;
const HORIZ_FACTOR = 5;
const MENU_HEIGHT_OFFSET = 132;
const NAVIGATION_REGION_OVERSHOOT = 50;

const ActivitiesMenuItem = new Lang.Class({
    Name: 'ActivitiesMenuItem',
    Extends: PopupMenu.PopupBaseMenuItem,

    _init: function(button) {
	this.parent();
        this._button = button;
        this.actor.add_child(new St.Label({ text: _("Activities Overview") }));
    },

    activate: function(event) {
        this._button.menu.toggle();
        Main.overview.toggle();
	this.parent(event);
    },
});

const ApplicationMenuItem = new Lang.Class({
    Name: 'ApplicationMenuItem',
    Extends: PopupMenu.PopupBaseMenuItem,

    _init: function(button, app) {
	this.parent();
	this._app = app;
        this._button = button;

        this._iconBin = new St.Bin();
        this.actor.add_child(this._iconBin);

        let appLabel = new St.Label({ text: app.get_name() });
        this.actor.add_child(appLabel, { expand: true });
        this.actor.label_actor = appLabel;

        let textureCache = St.TextureCache.get_default();
        let iconThemeChangedId = textureCache.connect('icon-theme-changed',
                                                      Lang.bind(this, this._updateIcon));
        this.actor.connect('destroy', Lang.bind(this,
            function() {
                textureCache.disconnect(iconThemeChangedId);
            }));
        this._updateIcon();
    },

    activate: function(event) {
	this._app.open_new_window(event.get_time());
        this._button.selectCategory(null, null);
        this._button.menu.toggle();
	this.parent(event);
    },

    setActive: function(active, params) {
        if (active)
            this._button.scrollToButton(this);
        this.parent(active, params);
    },

    _getPreferredWidth: function(actor, forHeight, alloc) {
        alloc.min_size = alloc.natural_size = -1;
    },

    _updateIcon: function() {
        this._iconBin.set_child(this._app.create_icon_texture(APPLICATION_ICON_SIZE));
    }
});

const CategoryMenuItem = new Lang.Class({
    Name: 'CategoryMenuItem',
    Extends: PopupMenu.PopupBaseMenuItem,

    _init: function(button, category) {
	this.parent();
	this._category = category;
        this._button = button;

        this._oldX = -1;
        this._oldY = -1;

        let name;
        if (this._category)
            name = this._category.get_name();
        else
            name = _("Favorites");

        this.actor.add_child(new St.Label({ text: name }));
        this.actor.connect('motion-event', Lang.bind(this, this._onMotionEvent));
    },

    activate: function(event) {
        this._button.selectCategory(this._category, this);
        this._button.scrollToCatButton(this);
	this.parent(event);
    },

    _isNavigatingSubmenu: function([x, y]) {
        let [posX, posY] = this.actor.get_transformed_position();

        if (this._oldX == -1) {
            this._oldX = x;
            this._oldY = y;
            return true;
        }

        let deltaX = Math.abs(x - this._oldX);
        let deltaY = Math.abs(y - this._oldY);

        this._oldX = x;
        this._oldY = y;

        // If it lies outside the x-coordinates then it is definitely outside.
        if (posX > x || posX + this.actor.width < x)
            return false;

        // If it lies inside the menu item then it is definitely inside.
        if (posY <= y && posY + this.actor.height >= y)
            return true;

        // We want the keep-up triangle only if the movement is more
        // horizontal than vertical.
        if (deltaX * HORIZ_FACTOR < deltaY)
            return false;

        // Check whether the point lies inside triangle ABC, and a similar
        // triangle on the other side of the menu item.
        //
        //   +---------------------+
        //   | menu item           |
        // A +---------------------+ C
        //              P          |
        //                         B

        // Ensure that the point P always lies below line AC so that we can
        // only check for triangle ABC.
        if (posY > y) {
            let offset = posY - y;
            y = posY + this.actor.height + offset;
        }

        // Ensure that A is (0, 0).
        x -= posX;
        y -= posY + this.actor.height;

        // Check which side of line AB the point P lies on by taking the
        // cross-product of AB and AP. See:
        // http://stackoverflow.com/questions/3461453/determine-which-side-of-a-line-a-point-lies
        if (((this.actor.width * y) - (NAVIGATION_REGION_OVERSHOOT * x)) <= 0)
             return true;

        return false;
    },

    _onMotionEvent: function(actor, event) {
        if (!Clutter.get_pointer_grab()) {
            this._oldX = -1;
            this._oldY = -1;
            Clutter.grab_pointer(this.actor);
        }
        this.actor.hover = true;

        if (this._isNavigatingSubmenu(event.get_coords()))
            return true;

        this._oldX = -1;
        this._oldY = -1;
        this.actor.hover = false;
        Clutter.ungrab_pointer();
        return false;
    },

    setActive: function(active, params) {
        if (active) {
            this._button.selectCategory(this._category, this);
            this._button.scrollToCatButton(this);
        }
        this.parent(active, params);
    }
});

const HotCorner = new Lang.Class({
    Name: 'HotCorner',
    Extends: Layout.HotCorner,

    _onCornerEntered : function() {
        if (!this._entered) {
            this._entered = true;
            if (!Main.overview.animationInProgress) {
                this._activationTime = Date.now() / 1000;
                this.rippleAnimation();
                Main.overview.toggle();
            }
        }
        return false;
    }
});

const ApplicationsMenu = new Lang.Class({
    Name: 'ApplicationsMenu',
    Extends: PopupMenu.PopupMenu,

    _init: function(sourceActor, arrowAlignment, arrowSide, button) {
        this.parent(sourceActor, arrowAlignment, arrowSide);
        this._button = button;
    },

    isEmpty: function() {
	return false;
    },

    open: function(animate) {
        this._button.hotCorner.setBarrierSize(0);
        if (this._button.hotCorner.actor) // fallback corner
            this._button.hotCorner.actor.hide();
        this.parent(animate);
    },

    close: function(animate) {
        let size = Main.layoutManager.panelBox.height;
        this._button.hotCorner.setBarrierSize(size);
        if (this._button.hotCorner.actor) // fallback corner
            this._button.hotCorner.actor.show();
        this.parent(animate);
    },

    toggle: function() {
        if (this.isOpen) {
            this._button.selectCategory(null, null);
        } else {
            if (Main.overview.visible)
                Main.overview.hide();
        }
        this.parent();
    }
});

const ApplicationsButton = new Lang.Class({
    Name: 'ApplicationsButton',
    Extends: PanelMenu.Button,

    _init: function() {
        this.parent(1.0, null, false);

        this.setMenu(new ApplicationsMenu(this.actor, 1.0, St.Side.TOP, this));
        Main.panel.menuManager.addMenu(this.menu);

        // At this moment applications menu is not keyboard navigable at
        // all (so not accessible), so it doesn't make sense to set as
        // role ATK_ROLE_MENU like other elements of the panel.
        this.actor.accessible_role = Atk.Role.LABEL;

        let hbox = new St.BoxLayout({ style_class: 'panel-status-menu-box' });

        this._label = new St.Label({ text: _("Applications"),
                                     y_expand: true,
                                     y_align: Clutter.ActorAlign.CENTER });
        hbox.add_child(this._label);
        hbox.add_child(new St.Label({ text: '\u25BE',
                                      y_expand: true,
                                      y_align: Clutter.ActorAlign.CENTER }));

        this.actor.add_actor(hbox);
        this.actor.name = 'panelApplications';
        this.actor.label_actor = this._label;

        this.actor.connect('captured-event', Lang.bind(this, this._onCapturedEvent));

        _showingId = Main.overview.connect('showing', Lang.bind(this, function() {
            this.actor.add_accessible_state (Atk.StateType.CHECKED);
        }));
        _hidingId = Main.overview.connect('hiding', Lang.bind(this, function() {
            this.actor.remove_accessible_state (Atk.StateType.CHECKED);
        }));

        this.reloadFlag = false;
        this._createLayout();
        this._display();
        _installedChangedId = appSys.connect('installed-changed', Lang.bind(this, function() {
            if (this.menu.isOpen) {
                this._redisplay();
                this.mainBox.show();
            } else {
                this.reloadFlag = true;
            }
        }));

        // Since the hot corner uses stage coordinates, Clutter won't
        // queue relayouts for us when the panel moves. Queue a relayout
        // when that happens.
        _panelBoxChangedId = Main.layoutManager.connect('panel-box-changed', Lang.bind(this, function() {
            container.queue_relayout();
        }));
    },

    get hotCorner() {
        return Main.layoutManager.hotCorners[Main.layoutManager.primaryIndex];
    },

    _createVertSeparator: function() {
        let separator = new St.DrawingArea({ style_class: 'calendar-vertical-separator',
                                             pseudo_class: 'highlighted' });
        separator.connect('repaint', Lang.bind(this, this._onVertSepRepaint));
        return separator;
    },

    _onCapturedEvent: function(actor, event) {
        if (event.type() == Clutter.EventType.BUTTON_PRESS) {
            if (!Main.overview.shouldToggleByCornerOrButton())
                return true;
        }
        return false;
    },

    _onMenuKeyPress: function(actor, event) {
        let symbol = event.get_key_symbol();
        if (symbol == Clutter.KEY_Left || symbol == Clutter.KEY_Right) {
            let direction = symbol == Clutter.KEY_Left ? Gtk.DirectionType.LEFT
                                                       : Gtk.DirectionType.RIGHT;
            if (this.menu.actor.navigate_focus(global.stage.key_focus, direction, false))
                return true;
        }
        return this.parent(actor, event);
    },

    _onVertSepRepaint: function(area) {
        let cr = area.get_context();
        let themeNode = area.get_theme_node();
        let [width, height] = area.get_surface_size();
        let stippleColor = themeNode.get_color('-stipple-color');
        let stippleWidth = themeNode.get_length('-stipple-width');
        let x = Math.floor(width/2) + 0.5;
        cr.moveTo(x, 0);
        cr.lineTo(x, height);
        Clutter.cairo_set_source_color(cr, stippleColor);
        cr.setDash([1, 3], 1); // Hard-code for now
        cr.setLineWidth(stippleWidth);
        cr.stroke();
    },

    _onOpenStateChanged: function(menu, open) {
       if (open) {
           if (this.reloadFlag) {
               this._redisplay();
               this.reloadFlag = false;
           }
           this.mainBox.show();
       }
       this.parent(menu, open);
    },

    _redisplay: function() {
        this.applicationsBox.destroy_all_children();
        this.categoriesBox.destroy_all_children();
        this._display();
    },

    _loadCategory: function(categoryId, dir) {
        let iter = dir.iter();
        let nextType;
        while ((nextType = iter.next()) != GMenu.TreeItemType.INVALID) {
            if (nextType == GMenu.TreeItemType.ENTRY) {
                let entry = iter.get_entry();
                if (!entry.get_app_info().get_nodisplay()) {
                    let app = appSys.lookup_app_by_tree_entry(entry);
                    let menu_id = dir.get_menu_id();
                    this.applicationsByCategory[categoryId].push(app);
                }
            } else if (nextType == GMenu.TreeItemType.DIRECTORY) {
                let subdir = iter.get_directory();
                if (!subdir.get_is_nodisplay())
                    this._loadCategory(categoryId, subdir);
            }
        }
    },

    scrollToButton: function(button) {
        let appsScrollBoxAdj = this.applicationsScrollBox.get_vscroll_bar().get_adjustment();
        let appsScrollBoxAlloc = this.applicationsScrollBox.get_allocation_box();
        let currentScrollValue = appsScrollBoxAdj.get_value();
        let boxHeight = appsScrollBoxAlloc.y2 - appsScrollBoxAlloc.y1;
        let buttonAlloc = button.actor.get_allocation_box();
        let newScrollValue = currentScrollValue;
        if (currentScrollValue > buttonAlloc.y1 - 10)
            newScrollValue = buttonAlloc.y1 - 10;
        if (boxHeight + currentScrollValue < buttonAlloc.y2 + 10)
            newScrollValue = buttonAlloc.y2 - boxHeight + 10;
        if (newScrollValue != currentScrollValue)
            appsScrollBoxAdj.set_value(newScrollValue);
    },

    scrollToCatButton: function(button) {
        let catsScrollBoxAdj = this.categoriesScrollBox.get_vscroll_bar().get_adjustment();
        let catsScrollBoxAlloc = this.categoriesScrollBox.get_allocation_box();
        let currentScrollValue = catsScrollBoxAdj.get_value();
        let boxHeight = catsScrollBoxAlloc.y2 - catsScrollBoxAlloc.y1;
        let buttonAlloc = button.actor.get_allocation_box();
        let newScrollValue = currentScrollValue;
        if (currentScrollValue > buttonAlloc.y1 - 10)
            newScrollValue = buttonAlloc.y1 - 10;
        if (boxHeight + currentScrollValue < buttonAlloc.y2 + 10)
            newScrollValue = buttonAlloc.y2 - boxHeight + 10;
        if (newScrollValue != currentScrollValue)
            catsScrollBoxAdj.set_value(newScrollValue);
    },

    _createLayout: function() {
        let section = new PopupMenu.PopupMenuSection();
        this.menu.addMenuItem(section);
        this.mainBox = new St.BoxLayout({ vertical: false });
        this.leftBox = new St.BoxLayout({ vertical: true });
        this.applicationsScrollBox = new St.ScrollView({ x_fill: true, y_fill: false,
                                                         y_align: St.Align.START,
                                                         style_class: 'apps-menu vfade' });
        this.applicationsScrollBox.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);
        let vscroll = this.applicationsScrollBox.get_vscroll_bar();
        vscroll.connect('scroll-start', Lang.bind(this, function() {
            this.menu.passEvents = true;
        }));
        vscroll.connect('scroll-stop', Lang.bind(this, function() {
            this.menu.passEvents = false;
        }));
        this.categoriesScrollBox = new St.ScrollView({ x_fill: true, y_fill: false,
                                                       y_align: St.Align.START,
                                                       style_class: 'vfade' });
        this.categoriesScrollBox.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);
        vscroll = this.categoriesScrollBox.get_vscroll_bar();
        vscroll.connect('scroll-start', Lang.bind(this, function() {
                              this.menu.passEvents = true;
                          }));
        vscroll.connect('scroll-stop', Lang.bind(this, function() {
            this.menu.passEvents = false;
        }));
        this.leftBox.add(this.categoriesScrollBox, { expand: true,
                                                     x_fill: true, y_fill: true,
                                                     y_align: St.Align.START });

        let activities = new ActivitiesMenuItem(this);
        this.leftBox.add(activities.actor, { expand: false,
                                             x_fill: true, y_fill: false,
                                             y_align: St.Align.START });

        this.applicationsBox = new St.BoxLayout({ vertical: true });
        this.applicationsScrollBox.add_actor(this.applicationsBox);
        this.categoriesBox = new St.BoxLayout({ vertical: true });
        this.categoriesScrollBox.add_actor(this.categoriesBox, { expand: true, x_fill: false });

        this.mainBox.add(this.leftBox);
        this.mainBox.add(this._createVertSeparator(), { expand: false, x_fill: false, y_fill: true});
        this.mainBox.add(this.applicationsScrollBox, { expand: true, x_fill: true, y_fill: true });
        section.actor.add_actor(this.mainBox);
    },

    _display: function() {
        this._applicationsButtons = new Array();
        this.mainBox.style=('width: 640px;');
        this.mainBox.hide();

        //Load categories
        this.applicationsByCategory = {};
        let tree = appSys.get_tree();
        let root = tree.get_root_directory();
        let categoryMenuItem = new CategoryMenuItem(this, null);
        this.categoriesBox.add_actor(categoryMenuItem.actor);
        let iter = root.iter();
        let nextType;
        while ((nextType = iter.next()) != GMenu.TreeItemType.INVALID) {
            if (nextType == GMenu.TreeItemType.DIRECTORY) {
                let dir = iter.get_directory();
                if (!dir.get_is_nodisplay()) {
                    let categoryId = dir.get_menu_id();
                    this.applicationsByCategory[categoryId] = [];
                    this._loadCategory(categoryId, dir);
                    if (this.applicationsByCategory[categoryId].length > 0) {
                        let categoryMenuItem = new CategoryMenuItem(this, dir);
                        this.categoriesBox.add_actor(categoryMenuItem.actor);
                    }
                }
            }
        }

        //Load applications
        this._displayButtons(this._listApplications(null));

        let height = this.categoriesBox.height + MENU_HEIGHT_OFFSET + 'px';
        this.mainBox.style+=('height: ' + height);
    },

    _clearApplicationsBox: function(selectedActor) {
        let actors = this.applicationsBox.get_children();
        for (let i = 0; i < actors.length; i++) {
            let actor = actors[i];
            this.applicationsBox.remove_actor(actor);
        }
    },

    selectCategory: function(dir, categoryMenuItem) {
        if (categoryMenuItem)
            this._clearApplicationsBox(categoryMenuItem.actor);
        else
            this._clearApplicationsBox(null);

        if (dir)
            this._displayButtons(this._listApplications(dir.get_menu_id()));
        else
            this._displayButtons(this._listApplications(null));
    },

    _displayButtons: function(apps) {
         if (apps) {
            for (let i = 0; i < apps.length; i++) {
               let app = apps[i];
               if (!this._applicationsButtons[app]) {
                  let applicationMenuItem = new ApplicationMenuItem(this, app);
                  this._applicationsButtons[app] = applicationMenuItem;
               }
               if (!this._applicationsButtons[app].actor.get_parent())
                  this.applicationsBox.add_actor(this._applicationsButtons[app].actor);
            }
         }
    },

    _listApplications: function(category_menu_id) {
        let applist;

        if (category_menu_id) {
            applist = this.applicationsByCategory[category_menu_id];
            applist.sort(function(a,b) {
                return a.get_name().toLowerCase() > b.get_name().toLowerCase();
            });
        } else {
            applist = new Array();
            let favorites = global.settings.get_strv('favorite-apps');
            for (let i = 0; i < favorites.length; i++) {
                let app = appSys.lookup_app(favorites[i]);
                if (app)
                    applist.push(app);
            }
        }

        return applist;
    },

    destroy: function() {
        this.menu.actor.get_children().forEach(function(c) { c.destroy() });
        this.parent();
    }
});

let appsMenuButton;
let activitiesButton;
let _hidingId;
let _installedChangedId;
let _panelBoxChangedId;
let _showingId;

function enable() {
    activitiesButton = Main.panel.statusArea['activities'];
    activitiesButton.container.hide();
    appsMenuButton = new ApplicationsButton();
    Main.panel.addToStatusArea('apps-menu', appsMenuButton, 1, 'left');

    Main.wm.setCustomKeybindingHandler('panel-main-menu',
                                       Shell.KeyBindingMode.NORMAL |
                                       Shell.KeyBindingMode.OVERVIEW,
                                       function() {
                                           appsMenuButton.menu.toggle();
                                       });
}

function disable() {
    Main.panel.menuManager.removeMenu(appsMenuButton.menu);
    appSys.disconnect(_installedChangedId);
    Main.layoutManager.disconnect(_panelBoxChangedId);
    Main.overview.disconnect(_hidingId);
    Main.overview.disconnect(_showingId);
    appsMenuButton.destroy();
    activitiesButton.container.show();

    Main.wm.setCustomKeybindingHandler('panel-main-menu',
                                       Shell.KeyBindingMode.NORMAL |
                                       Shell.KeyBindingMode.OVERVIEW,
                                       Main.sessionMode.hasOverview ?
                                       Lang.bind(Main.overview, Main.overview.toggle) :
                                       null);
}

function init(metadata) {
    Convenience.initTranslations();
}
