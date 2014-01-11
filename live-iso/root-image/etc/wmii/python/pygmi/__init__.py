import os
import sys

from pyxp.asyncclient import Client

if 'WMII_ADDRESS' in os.environ:
    client = Client(os.environ['WMII_ADDRESS'])
else:
    client = Client(namespace='wmii')

confpath = os.environ.get('WMII_CONFPATH', '%s/.wmii' % os.environ['HOME']).split(':')
shell = os.environ['SHELL']

sys.path += confpath

from pygmi.util import *
from pygmi.event import *
from pygmi.fs import *
from pygmi.menu import *
from pygmi.monitor import *
from pygmi import util, event, fs, menu, monitor

__all__ = (fs.__all__ + monitor.__all__ + event.__all__ +
           menu.__all__ + util.__all__ +
           ('client', 'confpath', 'shell'))

# vim:se sts=4 sw=4 et:
