from threading import Timer

from pygmi import client
from pygmi.fs import *

__all__ = 'monitors', 'defmonitor', 'Monitor'

monitors = {}

def defmonitor(*args, **kwargs):
    """
    Defines a new monitor to appear in wmii's bar based on
    the wrapped function. Creates a new Monitor object,
    initialized with *args and **kwargs. The wrapped function
    is assigned to the 'action' keyword argument for the
    Monitor, its name is assigned to the 'name' argument.

    The new monitor is added to the 'monitors' dict in this
    module.
    """
    def monitor(fn):
        kwargs['action'] = fn
        if not args and 'name' not in kwargs:
            kwargs['name'] = fn.__name__
        monitor = Monitor(*args, **kwargs)
        monitors[monitor.name] = monitor
        return monitor
    if args and callable(args[0]):
        fn = args[0]
        args = args[1:]
        return monitor(fn)
    return monitor

class Monitor(object):
    """
    A class to manage status monitors for wmii's bar. The bar item
    is updated on a fixed interval based on the values returned
    by the 'action' method.

    Property active: When true, the monitor is updated at regular
             intervals. When false, monitor is hidden.
    Property name: The name of the monitor, which acts as the name
           of the bar in wmii's filesystem.
    Property interval: The update interval, in seconds.
    Property side: The side of the bar on which to place the monitor.
    Property action: A function of no arguments which returns the
            value of the monitor. Called at each update interval.
            May return a string, a tuple of (Color, string), or None
            to hide the monitor for one iteration.
    """
    side = 'right'
    interval = 1.0

    def __init__(self, name=None, interval=None, side=None,
                 action=None, colors=None, label=None):
        """
        Initializes the new monitor. For parameter values, see the
        corresponding property values in the class's docstring.

        Param colors: The initial colors for the monitor.
        Param label:  The initial label for the monitor.
        """
        if side:
            self.side = side
        if name:
            self.name = name
        if interval:
            self.interval = interval
        if action:
            self.action = action

        self.timer = None
        self.button = Button(self.side, self.name, colors, label)
        self.tick()

    def tick(self):
        """
        Called internally at the interval defined by #interval.
        Calls #action and updates the monitor based on the result.
        """
        mon = monitors.get(self.name, None)
        if self.timer and mon is not self:
            return
        if self.active:
            label = self.getlabel()
            if isinstance(label, basestring):
                label = None, label
            if label is None:
                self.button.remove()
            else:
                self.button.create(*label)

            self.timer = Timer(self.interval, self.tick)
            self.timer.daemon = True
            self.timer.start()

    def getlabel(self):
        """
        Calls #action and returns the result, ignoring any
        exceptions.
        """
        try:
            return self.action(self)
        except Exception:
            return None

    _active = True
    def _set_active(self, val):
        self._active = bool(val)
        self.tick()
        if not val:
            self.button.remove()

    active = property(
        lambda self: self._active,
        _set_active)

# vim:se sts=4 sw=4 et:
