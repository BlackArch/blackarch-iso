// -*- mode: js2; indent-tabs-mode: nil; js2-basic-offset: 4 -*-
// import just everything from workspace.js:
const Clutter = imports.gi.Clutter;
const Gio = imports.gi.Gio;
const Lang = imports.lang;
const Mainloop = imports.mainloop;
const Meta = imports.gi.Meta;
const Pango = imports.gi.Pango;
const Shell = imports.gi.Shell;
const St = imports.gi.St;
const Signals = imports.signals;

const DND = imports.ui.dnd;
const Lightbox = imports.ui.lightbox;
const Main = imports.ui.main;
const Overview = imports.ui.overview;
const Panel = imports.ui.panel;
const Tweener = imports.ui.tweener;

const Workspace = imports.ui.workspace;
const WindowPositionFlags = Workspace.WindowPositionFlags;

const ExtensionUtils = imports.misc.extensionUtils;
const Me = ExtensionUtils.getCurrentExtension();
const Convenience = Me.imports.convenience;

// testing settings for natural window placement strategy:
const WINDOW_PLACEMENT_NATURAL_FILLGAPS = true;                     // enlarge windows at the end to fill gaps         // not implemented yet
const WINDOW_PLACEMENT_NATURAL_GRID_FALLBACK = true;                // fallback to grid mode if all windows have the same size and positions.     // not implemented yet
const WINDOW_PLACEMENT_NATURAL_ACCURACY = 20;                       // accuracy of window translate moves  (KDE-default: 20)
const WINDOW_PLACEMENT_NATURAL_GAPS = 5;                            // half of the minimum gap between windows
const WINDOW_PLACEMENT_NATURAL_MAX_TRANSLATIONS = 5000;             // safety limit for preventing endless loop if something is wrong in the algorithm

const PLACE_WINDOW_CAPTIONS_ON_TOP = true;                          // place window titles in overview on top of windows with overlap parameter

const WORKSPACE_BORDER_GAP = 10;                                    // minimum gap between the workspace area and the workspace selector
const WINDOW_AREA_TOP_GAP = 20;                                     // minimum gap between the workspace area and the top border. This keeps window captions and close buttons visible. 13px (26/2) should currently be enough.

const BUTTON_LAYOUT_SCHEMA = 'org.gnome.shell.overrides';
const BUTTON_LAYOUT_KEY = 'button-layout';

function injectToFunction(parent, name, func) {
    let origin = parent[name];
    parent[name] = function() {
        let ret;
        ret = origin.apply(this, arguments);
        if (ret === undefined)
            ret = func.apply(this, arguments);
        return ret;
    }
}

const Rect = new Lang.Class({
    Name: 'NativeWindowPlacement.Rect',

    _init: function(x, y, width, height) {
        [this.x, this.y, this.width, this.height] = [x, y, width, height];
    },

    /**
     * used in _calculateWindowTransformationsNatural to replace Meta.Rectangle that is too slow.
     */
    copy: function() {
        return new Rect(this.x, this.y, this.width, this.height);
    },

    union: function(rect2) {
        let dest = this.copy();
        if (rect2.x < dest.x)
          {
            dest.width += dest.x - rect2.x;
            dest.x = rect2.x;
          }
        if (rect2.y < dest.y)
          {
            dest.height += dest.y - rect2.y;
            dest.y = rect2.y;
          }
        if (rect2.x + rect2.width > dest.x + dest.width)
          dest.width = rect2.x + rect2.width - dest.x;
        if (rect2.y + rect2.height > dest.y + dest.height)
          dest.height = rect2.y + rect2.height - dest.y;

        return dest;
    },

    adjusted: function(dx, dy, dx2, dy2) {
        let dest = this.copy();
        dest.x += dx;
        dest.y += dy;
        dest.width += -dx + dx2;
        dest.height += -dy + dy2;
        return dest;
    },

    overlap: function(rect2) {
        return !((this.x + this.width    <= rect2.x) ||
                 (rect2.x + rect2.width  <= this.x) ||
                 (this.y + this.height   <= rect2.y) ||
                 (rect2.y + rect2.height <= this.y));
    },

    center: function() {
        return [this.x + this.width / 2, this.y + this.height / 2];
    },

    translate: function(dx, dy) {
        this.x += dx;
        this.y += dy;
    }
});

let winInjections, workspaceInjections, connectedSignals;

function resetState() {
    winInjections = { };
    workspaceInjections = { };
    connectedSignals = [ ];
}

function enable() {
    resetState();

    let settings = Convenience.getSettings();
    let useMoreScreen = settings.get_boolean('use-more-screen');
    let windowCaptionsOnTop = settings.get_boolean('window-captions-on-top');
    let signalId = settings.connect('changed::use-more-screen', function() {
        useMoreScreen = settings.get_boolean('use-more-screen');
    });
    connectedSignals.push({ obj: settings, id: signalId });

    /**
     * _calculateWindowTransformationsNatural:
     * @clones: Array of #MetaWindow
     *
     * Returns clones with matching target coordinates and scales to arrange windows in a natural way that no overlap exists and relative window size is preserved.
     * This function is almost a 1:1 copy of the function
     * PresentWindowsEffect::calculateWindowTransformationsNatural() from KDE, see:
     * https://projects.kde.org/projects/kde/kdebase/kde-workspace/repository/revisions/master/entry/kwin/effects/presentwindows/presentwindows.cpp
     */
    Workspace.Workspace.prototype._calculateWindowTransformationsNatural = function(clones, area) {
        // As we are using pseudo-random movement (See "slot") we need to make sure the list
        // is always sorted the same way no matter which window is currently active.

        let area_rect = new Rect(area.x, area.y, area.width, area.height);
        let bounds = area_rect.copy();

        let direction = 0;
        let directions = [];
        let rects = [];
        for (let i = 0; i < clones.length; i++) {
            // save rectangles into 4-dimensional arrays representing two corners of the rectangular: [left_x, top_y, right_x, bottom_y]
            let rect = clones[i].metaWindow.get_outer_rect();
            rects[i] = new Rect(rect.x, rect.y, rect.width, rect.height);
            bounds = bounds.union(rects[i]);

            // This is used when the window is on the edge of the screen to try to use as much screen real estate as possible.
            directions[i] = direction;
            direction++;
            if (direction == 4) {
                direction = 0;
            }
        }

        let loop_counter = 0;
        let overlap;
        do {
            overlap = false;
            for (let i = 0; i < rects.length; i++) {
                for (let j = 0; j < rects.length; j++) {
                    if (i != j && rects[i].adjusted(-WINDOW_PLACEMENT_NATURAL_GAPS, -WINDOW_PLACEMENT_NATURAL_GAPS,
                                                    WINDOW_PLACEMENT_NATURAL_GAPS, WINDOW_PLACEMENT_NATURAL_GAPS).overlap(
                                                     rects[j].adjusted(-WINDOW_PLACEMENT_NATURAL_GAPS, -WINDOW_PLACEMENT_NATURAL_GAPS,
                                                                       WINDOW_PLACEMENT_NATURAL_GAPS, WINDOW_PLACEMENT_NATURAL_GAPS))) {
                        loop_counter++;
                        overlap = true;

                        // TODO: something like a Point2D would be nicer here:

                        // Determine pushing direction
                        let i_center = rects[i].center();
                        let j_center = rects[j].center();
                        let diff = [j_center[0] - i_center[0], j_center[1] - i_center[1]];

                        // Prevent dividing by zero and non-movement
                        if (diff[0] == 0 && diff[1] == 0)
                            diff[0] = 1;
                        // Try to keep screen/workspace aspect ratio
                        if ( bounds.height / bounds.width > area_rect.height / area_rect.width )
                            diff[0] *= 2;
                        else
                            diff[1] *= 2;

                        // Approximate a vector of between 10px and 20px in magnitude in the same direction
                        let length = Math.sqrt(diff[0] * diff[0] + diff[1] * diff[1]);
                        diff[0] = diff[0] * WINDOW_PLACEMENT_NATURAL_ACCURACY / length;
                        diff[1] = diff[1] * WINDOW_PLACEMENT_NATURAL_ACCURACY / length;

                        // Move both windows apart
                        rects[i].translate(-diff[0], -diff[1]);
                        rects[j].translate(diff[0], diff[1]);


                        if (useMoreScreen) {
                            // Try to keep the bounding rect the same aspect as the screen so that more
                            // screen real estate is utilised. We do this by splitting the screen into nine
                            // equal sections, if the window center is in any of the corner sections pull the
                            // window towards the outer corner. If it is in any of the other edge sections
                            // alternate between each corner on that edge. We don't want to determine it
                            // randomly as it will not produce consistant locations when using the filter.
                            // Only move one window so we don't cause large amounts of unnecessary zooming
                            // in some situations. We need to do this even when expanding later just in case
                            // all windows are the same size.
                            // (We are using an old bounding rect for this, hopefully it doesn't matter)
                            let xSection = Math.round((rects[i].x - bounds.x) / (bounds.width / 3));
                            let ySection = Math.round((rects[i].y - bounds.y) / (bounds.height / 3));

                            let i_center = rects[i].center();
                            diff[0] = 0;
                            diff[1] = 0;
                            if (xSection != 1 || ySection != 1) { // Remove this if you want the center to pull as well
                                if (xSection == 1)
                                    xSection = (directions[i] / 2 ? 2 : 0);
                                if (ySection == 1)
                                    ySection = (directions[i] % 2 ? 2 : 0);
                            }
                            if (xSection == 0 && ySection == 0) {
                                diff[0] = bounds.x - i_center[0];
                                diff[1] = bounds.y - i_center[1];
                            }
                            if (xSection == 2 && ySection == 0) {
                                diff[0] = bounds.x + bounds.width - i_center[0];
                                diff[1] = bounds.y - i_center[1];
                            }
                            if (xSection == 2 && ySection == 2) {
                                diff[0] = bounds.x + bounds.width - i_center[0];
                                diff[1] = bounds.y + bounds.height - i_center[1];
                            }
                            if (xSection == 0 && ySection == 2) {
                                diff[0] = bounds.x - i_center[0];
                                diff[1] = bounds.y + bounds.height - i_center[1];
                            }
                            if (diff[0] != 0 || diff[1] != 0) {
                                let length = Math.sqrt(diff[0]*diff[0] + diff[1]*diff[1]);
                                diff[0] *= WINDOW_PLACEMENT_NATURAL_ACCURACY / length / 2;   // /2 to make it less influencing than the normal center-move above
                                diff[1] *= WINDOW_PLACEMENT_NATURAL_ACCURACY / length / 2;
                                rects[i].translate(diff[0], diff[1]);
                            }
                        }

                        // Update bounding rect
                        bounds = bounds.union(rects[i]);
                        bounds = bounds.union(rects[j]);
                    }
                }
            }
        } while (overlap && loop_counter < WINDOW_PLACEMENT_NATURAL_MAX_TRANSLATIONS);

        // Work out scaling by getting the most top-left and most bottom-right window coords.
        let scale;
        scale = Math.min(area_rect.width / bounds.width,
                         area_rect.height / bounds.height,
                         1.0);

        // Make bounding rect fill the screen size for later steps
        bounds.x = bounds.x - (area_rect.width - bounds.width * scale) / 2;
        bounds.y = bounds.y - (area_rect.height - bounds.height * scale) / 2;
        bounds.width = area_rect.width / scale;
        bounds.height = area_rect.height / scale;

        // Move all windows back onto the screen and set their scale
        for (let i = 0; i < rects.length; i++) {
            rects[i].translate(-bounds.x, -bounds.y);
        }

        // TODO: Implement the KDE part "Try to fill the gaps by enlarging windows if they have the space" here. (If this is wanted)

        // rescale to workspace
        let scales = [];

        let buttonOuterHeight, captionHeight;
        let buttonOuterWidth = 0;

        let slots = [];
        for (let i = 0; i < rects.length; i++) {
            rects[i].x = rects[i].x * scale + area_rect.x;
            rects[i].y = rects[i].y * scale + area_rect.y;

            slots.push([rects[i].x, rects[i].y, scale, clones[i]]);
        }

        return slots;
    }
    workspaceInjections['_calculateWindowTransformationsNatural'] = undefined;

    /**
     * _updateWindowPositions:
     * @flags:
     *  INITIAL - this is the initial positioning of the windows.
     *  ANIMATE - Indicates that we need animate changing position.
     */
    workspaceInjections['_updateWindowPositions'] = Workspace.Workspace.prototype._updateWindowPositions;
    Workspace.Workspace.prototype._updateWindowPositions = function(flags) {
            if (this._currentLayout == null) {
                this._recalculateWindowPositions(flags);
                return;
            }

            let initialPositioning = flags & WindowPositionFlags.INITIAL;
            let animate = flags & WindowPositionFlags.ANIMATE;

            let layout = this._currentLayout;
            let strategy = layout.strategy;

            let [, , padding] = this._getSpacingAndPadding();
            let area = Workspace.padArea(this._actualGeometry, padding);

            /// EDIT replace this version by our own:
            //let slots = strategy.computeWindowSlots(layout, area);


            /// EDIT copied from _realRecalculateWindowPositions:
            let clones = this._windows.slice();
            if (clones.length == 0)
                return;

            clones.sort(function(a, b) {
                return a.metaWindow.get_stable_sequence() - b.metaWindow.get_stable_sequence();
            });

            if (this._reservedSlot)
                clones.push(this._reservedSlot);

            /// EDIT our own window placement function:
            let slots = this._calculateWindowTransformationsNatural(clones, area);


            let currentWorkspace = global.screen.get_active_workspace();
            let isOnCurrentWorkspace = this.metaWorkspace == null || this.metaWorkspace == currentWorkspace;

            for (let i = 0; i < slots.length; i++) {
                let slot = slots[i];
                let [x, y, scale, clone] = slot;
                let metaWindow = clone.metaWindow;
                let overlay = clone.overlay;
                clone.slotId = i;

                // Positioning a window currently being dragged must be avoided;
                // we'll just leave a blank spot in the layout for it.
                if (clone.inDrag)
                    continue;

                let cloneWidth = clone.actor.width * scale;
                let cloneHeight = clone.actor.height * scale;
                clone.slot = [x, y, cloneWidth, cloneHeight];

                if (overlay && (initialPositioning || !clone.positioned))
                    overlay.hide();

                if (!clone.positioned) {
                    // This window appeared after the overview was already up
                    // Grow the clone from the center of the slot
                    clone.actor.x = x + cloneWidth / 2;
                    clone.actor.y = y + cloneHeight / 2;
                    clone.actor.scale_x = 0;
                    clone.actor.scale_y = 0;
                    clone.positioned = true;
                }

                if (animate && isOnCurrentWorkspace) {
                    if (!metaWindow.showing_on_its_workspace()) {
                        /* Hidden windows should fade in and grow
                         * therefore we need to resize them now so they
                         * can be scaled up later */
                        if (initialPositioning) {
                            clone.actor.opacity = 0;
                            clone.actor.scale_x = 0;
                            clone.actor.scale_y = 0;
                            clone.actor.x = x;
                            clone.actor.y = y;
                        }

                        Tweener.addTween(clone.actor,
                                         { opacity: 255,
                                           time: Overview.ANIMATION_TIME,
                                           transition: 'easeInQuad'
                                         });
                    }

                    this._animateClone(clone, overlay, x, y, scale, initialPositioning);
                } else {
                    // cancel any active tweens (otherwise they might override our changes)
                    Tweener.removeTweens(clone.actor);
                    clone.actor.set_position(x, y);
                    clone.actor.set_scale(scale, scale);
                    clone.overlay.relayout(false);
                    this._showWindowOverlay(clone, overlay, isOnCurrentWorkspace);
                }
            }
        }



    /// position window titles on top of windows in overlay ////
    if (windowCaptionsOnTop) {

        /// This is almost a direct copy of the original relayout function. Differences are marked.
        winInjections['relayout'] = Workspace.WindowOverlay.prototype.relayout;
        Workspace.WindowOverlay.prototype.relayout = function(animate) {
            let button = this.closeButton;
            let title = this.title;
            let border = this.border;

            Tweener.removeTweens(button);
            Tweener.removeTweens(title);
            Tweener.removeTweens(border);

            let [cloneX, cloneY, cloneWidth, cloneHeight] = this._windowClone.slot;

            let layout = Meta.prefs_get_button_layout();
            let side = layout.left_buttons.indexOf(Meta.ButtonFunction.CLOSE) > -1 ? St.Side.LEFT : St.Side.RIGHT;

            let buttonX;
            let buttonY = cloneY - (button.height - button._overlap);
            if (side == St.Side.LEFT)
                buttonX = cloneX - (button.width - button._overlap);
            else
                buttonX = cloneX + (cloneWidth - button._overlap);

            if (animate)
                this._animateOverlayActor(button, Math.floor(buttonX), Math.floor(buttonY), button.width);
            else
                button.set_position(Math.floor(buttonX), Math.floor(buttonY));

            // Clutter.Actor.get_preferred_width() will return the fixed width if one
            // is set, so we need to reset the width by calling set_width(-1), to forward
            // the call down to StLabel.
            // We also need to save and restore the current width, otherwise the animation
            // starts from the wrong point.
            let prevTitleWidth = title.width;
            title.set_width(-1);
            let [titleMinWidth, titleNatWidth] = title.get_preferred_width(-1);
            let titleWidth = Math.max(titleMinWidth, Math.min(titleNatWidth, cloneWidth));
            title.width = prevTitleWidth;

            let titleX = cloneX + (cloneWidth - titleWidth) / 2;

            /// this is the actual difference to original gnome-shell:
            //let titleY = cloneY + cloneHeight + title._spacing;
            let titleY = cloneY - title.height + title._spacing;

            if (animate)
                this._animateOverlayActor(title, Math.floor(titleX), Math.floor(titleY), titleWidth);
            else {
                title.width = titleWidth;
                title.set_position(Math.floor(titleX), Math.floor(titleY));
            }

            let borderX = cloneX - this.borderSize;
            let borderY = cloneY - this.borderSize;
            let borderWidth = cloneWidth + 2 * this.borderSize;
            let borderHeight = cloneHeight + 2 * this.borderSize;

            if (animate) {
                this._animateOverlayActor(this.border, borderX, borderY,
                                          borderWidth, borderHeight);
            } else {
                this.border.set_position(borderX, borderY);
                this.border.set_size(borderWidth, borderHeight);
            }
        };
    }
}

function removeInjection(object, injection, name) {
    if (injection[name] === undefined)
        delete object[name];
    else
        object[name] = injection[name];
}

function disable() {
    var i;

    for (i in workspaceInjections)
        removeInjection(Workspace.Workspace.prototype, workspaceInjections, i);
    for (i in winInjections)
        removeInjection(Workspace.WindowOverlay.prototype, winInjections, i);

    for each (i in connectedSignals)
        i.obj.disconnect(i.id);

    global.stage.queue_relayout();
    resetState();
}

function init() {
    /* do nothing */
}
