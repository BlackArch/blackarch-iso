import os
import subprocess

import pygmi

__all__ = 'call', 'message', 'program_list', 'curry', 'find_script', '_', 'prop'

def _():
    pass

def call(*args, **kwargs):
    background = kwargs.pop('background', False)
    input = kwargs.pop('input', None)
    p = subprocess.Popen(args, stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                         stderr=subprocess.PIPE, cwd=os.environ['HOME'],
                         close_fds=True, **kwargs)
    if not background:
        return p.communicate(input)[0].rstrip('\n')

def message(message):
    args = ['xmessage', '-file', '-'];
    font = pygmi.wmii['font']
    if not font.startswith('xft:'):
        args += ['-fn', font.split(',')[0]]
    call(*args, input=message)

def program_list(path):
    names = []
    for d in path:
        try:
            for f in os.listdir(d):
                p = '%s/%s' % (d, f)
                if f not in names and os.access(p, os.X_OK) and (
                    os.path.isfile(p) or os.path.islink(p)):
                    names.append(f)
        except Exception:
            pass
    return sorted(names)

def curry(func, *args, **kwargs):
    if _ in args:
        blank = [i for i in range(0, len(args)) if args[i] is _]
        def curried(*newargs, **newkwargs):
            ary = list(args)
            for k, v in zip(blank, newargs):
                ary[k] = v
            ary = tuple(ary) + newargs[len(blank):]
            return func(*ary, **dict(kwargs, **newkwargs))
    else:
        def curried(*newargs, **newkwargs):
            return func(*(args + newargs), **dict(kwargs, **newkwargs))
    curried.__name__ = func.__name__ + '__curried__'
    return curried

def find_script(name):
    for path in pygmi.confpath:
        if os.access('%s/%s' % (path, name), os.X_OK):
            return '%s/%s' % (path, name)

def prop(**kwargs):
    def prop_(wrapped):
        kwargs['fget'] = wrapped
        return property(**kwargs)
    return prop_

# vim:se sts=4 sw=4 et:
