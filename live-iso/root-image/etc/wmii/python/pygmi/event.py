import os
import re
import sys
import traceback

import pygmi
from pygmi.util import prop
from pygmi import monitor, client, curry, call, program_list, _

__all__ = ('keys', 'events', 'Match')

class Match(object):
    """
    A class used for matching events based on simple patterns.
    """
    def __init__(self, *args):
        """
        Creates a new Match object based on arbitrary arguments
        which constitute a match pattern. Each argument matches an
        element of the original event. Arguments are matched based
        on their type:

            _:      Matches anything
            set:    Matches any string equal to any of its elements
            list:   Matches any string equal to any of its elements
            tuple:  Matches any string equal to any of its elements

        Additionally, any type with a 'search' attribute matches if
        that callable attribute returns True given element in
        question as its first argument.

        Any other object matches if it compares equal to the
        element.
        """
        self.args = args
        self.matchers = []
        for a in args:
            if a is _:
                a = lambda k: True
            elif isinstance(a, basestring):
                a = a.__eq__
            elif isinstance(a, (list, tuple, set)):
                a = curry(lambda ary, k: k in ary, a)
            elif hasattr(a, 'search'):
                a = a.search
            else:
                a = str(a).__eq__
            self.matchers.append(a)

    def match(self, string):
        """
        Returns true if this object matches an arbitrary string when
        split on ascii spaces.
        """
        ary = string.split(' ', len(self.matchers))
        if all(m(a) for m, a in zip(self.matchers, ary)):
            return ary

def flatten(items):
    """
    Given an iterator which returns (key, value) pairs, returns a
    new iterator of (k, value) pairs such that every list- or
    tuple-valued key in the original sequence yields an individual
    pair.

    Example: flatten({(1, 2, 3): 'foo', 4: 'bar'}.items()) ->
        (1, 'foo'), (2: 'foo'), (3: 'foo'), (4: 'bar')
    """
    for k, v in items:
        if not isinstance(k, (list, tuple)):
            k = k,
        for key in k:
            yield key, v

class Events():
    """
    A class to handle events read from wmii's '/event' file.
    """
    def __init__(self):
        """
        Initializes the event handler
        """
        self.events = {}
        self.eventmatchers = {}
        self.alive = True

    def dispatch(self, event, args=''):
        """
        Distatches an event to any matching event handlers.

        The handler which specifically matches the event name will
        be called first, followed by any handlers with a 'match'
        method which matches the event name concatenated to the args
        string.

        Param event: The name of the event to dispatch.
        Param args:  The single arguments string for the event.
        """
        try:
            if event in self.events:
                self.events[event](args)
            for matcher, action in self.eventmatchers.iteritems():
                ary = matcher.match(' '.join((event, args)))
                if ary is not None:
                    action(*ary)
        except Exception, e:
            traceback.print_exc(sys.stderr)

    def loop(self):
        """
        Enters the event loop, reading lines from wmii's '/event'
        and dispatching them, via #dispatch, to event handlers.
        Continues so long as #alive is True.
        """
        keys.mode = 'main'
        for line in client.readlines('/event'):
            if not self.alive:
                break
            self.dispatch(*line.split(' ', 1))
        self.alive = False

    def bind(self, items={}, **kwargs):
        """
        Binds a number of event handlers for wmii events. Keyword
        arguments other than 'items' are added to the 'items' dict.
        Handlers are called by #loop when a matching line is read
        from '/event'. Each handler is called with, as its sole
        argument, the string read from /event with its first token
        stripped.

        Param items: A dict of action-handler pairs to bind. Passed
            through pygmi.event.flatten. Keys with a 'match' method,
            such as pygmi.event.Match objects or regular expressions,
            are matched against the entire event string. Any other
            object matches if it compares equal to the first token of
            the event.
        """
        kwargs.update(items)
        for k, v in flatten(kwargs.iteritems()):
            if hasattr(k, 'match'):
                self.eventmatchers[k] = v
            else:
                self.events[k] = v

    def event(self, fn):
        """
        A decorator which binds its wrapped function, as via #bind,
        for the event which matches its name.
        """
        self.bind({fn.__name__: fn})
events = Events()

class Keys(object):
    """
    A class to manage wmii key bindings.
    """
    def __init__(self):
        """
        Initializes the class and binds an event handler for the Key
        event, as via pygmi.event.events.bind.

        Takes no arguments.
        """
        self.modes = {}
        self.modelist = []
        self._set_mode('main', False)
        self.defs = {}
        events.bind(Key=self.dispatch)

    def _add_mode(self, mode):
        if mode not in self.modes:
            self.modes[mode] = {
                'name': mode,
                'desc': {},
                'groups': [],
                'keys': {},
                'import': {},
            }
            self.modelist.append(mode)

    def _set_mode(self, mode, execute=True):
        self._add_mode(mode)
        self._mode = mode
        self._keys = dict((k % self.defs, v) for k, v in
                          self.modes[mode]['keys'].items() +
                          self.modes[mode]['import'].items());
        if execute:
            client.write('/keys', '\n'.join(self._keys.keys()) + '\n')

    mode = property(lambda self: self._mode, _set_mode,
                   doc="The current mode for which to dispatch keys")

    @prop(doc="Returns a short help text describing the bound keys in all modes")
    def help(self):
        return '\n\n'.join(
            ('Mode %s\n' % mode['name']) +
            '\n\n'.join(('  %s\n' % str(group or '')) +
                        '\n'.join('    %- 20s %s' % (key % self.defs,
                                                     mode['keys'][key].__doc__)
                                  for key in mode['desc'][group])
                        for group in mode['groups'])
            for mode in (self.modes[name]
                         for name in self.modelist))

    def bind(self, mode='main', keys=(), import_={}):
        """
        Binds a series of keys for the given 'mode'. Keys may be
        specified as a dict or as a sequence of tuple values and
        strings.
        
        In the latter case, documentation may be interspersed with
        key bindings. Any value in the sequence which is not a tuple
        begins a new key group, with that value as a description.
        A tuple with two values is considered a key-value pair,
        where the value is the handler for the named key. A
        three valued tuple is considered a key-description-value
        tuple, with the same semantics as above.

        Each key binding is interpolated with the values of
        #defs, as if processed by (key % self.defs)

        Param mode: The name of the mode for which to bind the keys.
        Param keys: A sequence of keys to bind.
        Param import_: A dict specifying keys which should be
                       imported from other modes, of the form 
                         { 'mode': ['key1', 'key2', ...] }
        """
        self._add_mode(mode)
        mode = self.modes[mode]
        group = None
        def add_desc(key, desc):
            if group not in mode['desc']:
                mode['desc'][group] = []
                mode['groups'].append(group)
            if key not in mode['desc'][group]:
                mode['desc'][group].append(key);

        if isinstance(keys, dict):
            keys = keys.iteritems()
        for obj in keys:
            if isinstance(obj, tuple) and len(obj) in (2, 3):
                if len(obj) == 2:
                    key, val = obj
                    desc = ''
                elif len(obj) == 3:
                    key, desc, val = obj
                mode['keys'][key] = val
                add_desc(key, desc)
                val.__doc__ = str(desc)
            else:
                group = obj

        def wrap_import(mode, key):
            return lambda k: self.modes[mode]['keys'][key](k)
        for k, v in flatten((v, k) for k, v in import_.iteritems()):
            mode['import'][k % self.defs] = wrap_import(v, k)

    def dispatch(self, key):
        """
        Dispatches a key event for the current mode.

        Param key: The key spec for which to dispatch.
        """
        mode = self.modes[self.mode]
        if key in self._keys:
            return self._keys[key](key)
keys = Keys()

class Actions(object):
    """
    A class to represent user-callable actions. All methods without
    leading underscores in their names are treated as callable actions.
    """
    def __getattr__(self, name):
        if name.startswith('_') or name.endswith('_'):
            raise AttributeError()
        if hasattr(self, name + '_'):
            return getattr(self, name + '_')
        def action(args=''):
            cmd = pygmi.find_script(name)
            if cmd:
                call(pygmi.shell, '-c', '$* %s' % args, '--', cmd,
                     background=True)
        return action

    def _call(self, args):
        """
        Calls a method named for the first token of 'args', with the
        rest of the string as its first argument. If the method
        doesn't exist, a trailing underscore is appended.
        """
        a = args.split(' ', 1)
        if a:
            getattr(self, a[0])(*a[1:])

    @prop(doc="Returns the names of the public methods callable as actions, with trailing underscores stripped.")
    def _choices(self):
        return sorted(
            program_list(pygmi.confpath) +
            [re.sub('_$', '', k) for k in dir(self)
             if not re.match('^_', k) and callable(getattr(self, k))])


# vim:se sts=4 sw=4 et:
