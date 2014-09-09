from threading import Thread
from pygmi.util import call

__all__ = 'Menu', 'ClickMenu'

def inthread(args, action, **kwargs):
    fn = lambda: call(*args, **kwargs)
    if not action:
        return fn()
    t = Thread(target=lambda: action(fn()))
    t.daemon = True
    t.start()

class Menu(object):
    def __init__(self, choices=(), action=None,
                 histfile=None, nhist=None):
        self.choices = choices
        self.action = action
        self.histfile = histfile
        self.nhist = nhist

    def __call__(self, choices=None):
        if choices is None:
            choices = self.choices
        if callable(choices):
            choices = choices()
        args = ['wimenu']
        if self.histfile:
            args += ['-h', self.histfile]
        if self.nhist:
            args += ['-n', self.nhist]
        return inthread(map(str, args), self.action, input='\n'.join(choices))
    call = __call__

class ClickMenu(object):
    def __init__(self, choices=(), action=None,
                 histfile=None, nhist=None):
        self.choices = choices
        self.action = action
        self.prev = None

    def __call__(self, choices=None):
        if choices is None:
            choices = self.choices
        if callable(choices):
            choices = choices()
        args = ['wmii9menu']
        if self.prev:
            args += ['-i', self.prev]
        args += ['--'] + list(choices)
        return inthread(map(str, args), self.action)
    call = __call__

# vim:se sts=4 sw=4 et:
