import collections
from datetime import datetime, timedelta

from pyxp import *
from pyxp.client import *
from pygmi import *
from pygmi.util import prop

__all__ = ('wmii', 'Tags', 'Tag', 'Area', 'Frame', 'Client',
           'Button', 'Colors', 'Color')

def constrain(min, max, val):
    if val < min:
        return min
    if val > max:
        return max
    return val

class Ctl(object):
    """
    An abstract class to represent the 'ctl' files of the wmii filesystem.
    Instances act as live, writable dictionaries of the settings represented
    in the file.

    Abstract roperty ctl_path: The path to the file represented by this
            control.
    Property ctl_hasid: When true, the first line of the represented
            file is treated as an id, rather than a key-value pair. In this
            case, the value is available via the 'id' property.
    Property ctl_types: A dict mapping named dictionary keys to two valued
            tuples, each containing a decoder and encoder function for the
            property's plain text value.
    """
    sentinel = {}
    ctl_types = {}
    ctl_hasid = False

    def __eq__(self, other):
        if self.ctl_hasid and isinstance(other, Ctl) and other.ctl_hasid:
            return self.id == other.id
        return False

    def __init__(self):
        self.cache = {}

    def ctl(self, *args):
        """
        Arguments are joined by ascii spaces and written to the ctl file.
        """
        client.awrite(self.ctl_path, ' '.join(args))

    def __getitem__(self, key):
        for line in self.ctl_lines():
            key_, rest = line.split(' ', 1)
            if key_ == key:
                if key in self.ctl_types:
                    return self.ctl_types[key][0](rest)
                return rest
        raise KeyError()
    def __hasitem__(self, key):
        return key in self.keys()
    def __setitem__(self, key, val):
        assert '\n' not in key
        self.cache[key] = val
        if key in self.ctl_types:
            val = self.ctl_types[key][1](val)
        self.ctl(key, val)

    def get(self, key, default=sentinel):
        """
        Gets the instance's dictionary value for 'key'. If the key doesn't
        exist, 'default' is returned. If 'default' isn't provided and the key
        doesn't exist, a KeyError is raised.
        """
        try:
            val = self[key]
        except KeyError, e:
            if default is not self.sentinel:
                return default
            raise e
    def set(self, key, val):
        """
        Sets the dictionary value for 'key' to 'val', as self[key] = val
        """
        self[key] = val

    def keys(self):
        return [line.split(' ', 1)[0]
                for line in self.ctl_lines()]
    def iteritems(self):
        return (tuple(line.split(' ', 1))
                for line in self.ctl_lines())
    def items(self):
        return [tuple(line.split(' ', 1))
                for line in self.ctl_lines()]

    def ctl_lines(self):
        """
        Returns the lines of the ctl file as a tuple, with the first line
        stripped if #ctl_hasid is set.
        """
        lines = tuple(client.readlines(self.ctl_path))
        if self.ctl_hasid:
            lines = lines[1:]
        return lines

    _id = None
    @prop(doc="If #ctl_hasid is set, returns the id of this ctl file.")
    def id(self):
        if self._id is None and self.ctl_hasid:
            return client.read(self.ctl_path).split('\n', 1)[0]
        return self._id

class Dir(Ctl):
    """
    An abstract class representing a directory in the wmii filesystem with a
    ctl file and sub-objects.

    Abstract property base_path: The path directly under which all objects
            represented by this class reside. e.g., /client, /tag
    """
    ctl_hasid = True

    def __init__(self, id):
        """
        Initializes the directory object.

        Param id: The id of the object in question. If 'sel', the object
                dynamically represents the selected object, even as it
                changes. In this case, #id will return the actual ID of the
                object.
        """
        super(Dir, self).__init__()
        if isinstance(id, Dir):
            id = id.id
        if id != 'sel':
            self._id = id

    def __eq__(self, other):
        return (self.__class__ == other.__class__ and
                self.id == other.id)

    class ctl_property(object):
        """
        A class which maps instance properties to ctl file properties.
        """
        def __init__(self, key):
            self.key = key
        def __get__(self, dir, cls):
            return dir[self.key]
        def __set__(self, dir, val):
            dir[self.key] = val

    class toggle_property(ctl_property):
        """
        A class which maps instance properties to ctl file properties. The
        values True and False map to the strings "on" and "off" in the
        filesystem.
        """
        props = {
            'on': True,
            'off': False,
        }
        def __get__(self, dir, cls):
            val = dir[self.key]
            if val in self.props:
                return self.props[val]
            return val
        def __set__(self, dir, val):
            for k, v in self.props.iteritems():
                if v == val:
                    val = k
                    break
            dir[self.key] = val

    class file_property(object):
        """
        A class which maps instance properties to files in the directory
        represented by this object.
        """
        def __init__(self, name, writable=False):
            self.name = name
            self.writable = writable
        def __get__(self, dir, cls):
            return client.read('%s/%s' % (dir.path, self.name))
        def __set__(self, dir, val):
            if not self.writable:
                raise NotImplementedError('File %s is not writable' % self.name)
            return client.awrite('%s/%s' % (dir.path, self.name),
                                 str(val))

    @prop(doc="The path to this directory's ctl file")
    def ctl_path(self):
        return '%s/ctl' % self.path

    @prop(doc="The path to this directory")
    def path(self):
        return '%s/%s' % (self.base_path, self._id or 'sel')

    @classmethod
    def all(cls):
        """
        Returns all of the objects that exist for this type of directory.
        """
        return (cls(s.name)
                for s in client.readdir(cls.base_path)
                if s.name != 'sel')

    def __repr__(self):
        return '%s(%s)' % (self.__class__.__name__,
                           repr(self._id or 'sel'))

class Client(Dir):
    """
    A class which represents wmii clients. Maps to the directories directly
    below /client.
    """
    base_path = '/client'

    fullscreen = Dir.toggle_property('Fullscreen')
    urgent = Dir.toggle_property('Urgent')

    label = Dir.file_property('label', writable=True)
    tags  = Dir.file_property('tags', writable=True)
    props = Dir.file_property('props')

    def kill(self):
        """Politely asks a client to quit."""
        self.ctl('kill')
    def slay(self):
        """Forcibly severs a client's connection to the X server."""
        self.ctl('slay')

class liveprop(object):
    def __init__(self, get):
        self.get = get
        self.attr = str(self)
    def __get__(self, area, cls):
        if getattr(area, self.attr, None) is not None:
            return getattr(area, self.attr)
        return self.get(area)
    def __set__(self, area, val):
        setattr(area, self.attr, val)

class Area(object):
    def __init__(self, tag, ord, screen='sel', offset=None, width=None, height=None, frames=None):
        self.tag = tag
        if ':' in str(ord):
            screen, ord = ord.split(':', 2)
        self.ord = str(ord)
        self.screen = str(screen)
        self.offset = offset
        self.width = width
        self.height = height
        self.frames = frames

    def prop(key):
        @liveprop
        def prop(self):
            for area in self.tag.index:
                if str(area.ord) == str(self.ord):
                    return getattr(area, key)
        return prop
    offset = prop('offset')
    width = prop('width')
    height = prop('height')
    frames = prop('frames')

    @property
    def spec(self):
        return '%s:%s' % (self.screen, self.ord)

    def _get_mode(self):
        for k, v in self.tag.iteritems():
            if k == 'colmode':
                v = v.split(' ')
                if v[0] == self.ord:
                    return v[1]
    mode = property(
        _get_mode,
        lambda self, val: self.tag.set('colmode %s' % self.spec, val))

    def grow(self, dir, amount=None):
        self.tag.grow(self, dir, amount)
    def nudge(self, dir, amount=None):
        self.tag.nudge(self, dir, amount)

class Frame(object):
    live = False

    def __init__(self, client, area=None, ord=None, offset=None, height=None):
        self.client = client
        self.ord = ord
        self.offset = offset
        self.height = height

    @property
    def width(self):
        return self.area.width

    def prop(key):
        @liveprop
        def prop(self):
            for area in self.tag.index:
                for frame in area.frames:
                    if frame.client == self.client:
                        return getattr(frame, key)
        return prop
    offset = prop('area')
    offset = prop('ord')
    offset = prop('offset')
    height = prop('height')

    def grow(self, dir, amount=None):
        self.area.tag.grow(self, dir, amount)
    def nudge(self, dir, amount=None):
        self.area.tag.nudge(self, dir, amount)

class Tag(Dir):
    base_path = '/tag'

    @classmethod
    def framespec(cls, frame):
        if isinstance(frame, Frame):
            frame = frame.client
        if isinstance(frame, Area):
            frame = (frame.ord, 'sel')
        if isinstance(frame, Client):
            if frame._id is None:
                return 'sel sel'
            return 'client %s' % frame.id
        elif isinstance(frame, basestring):
            return frame
        else:
            return '%s %s' % tuple(map(str, frame))
    def dirspec(cls, dir):
        if isinstance(dir, tuple):
            dir = ' '.join(dir)
        return dir

    def _set_selected(self, frame):
        if not isinstance(frame, basestring) or ' ' not in frame:
            frame = self.framespec(frame)
        self['select'] = frame
    selected = property(lambda self: tuple(self['select'].split(' ')),
                        _set_selected)

    def _get_selclient(self):
        for k, v in self.iteritems():
            if k == 'select' and 'client' in v:
                return Client(v.split(' ')[1])
        return None
    selclient = property(_get_selclient,
                         lambda self, val: self.set('select',
                                                    self.framespec(val)))

    @property
    def selcol(self):
        return Area(self, self.selected[0])

    @property
    def index(self):
        areas = []
        for l in [l.split(' ')
                  for l in client.readlines('%s/index' % self.path)
                  if l]:
            if l[0] == '#':
                m = re.match(r'(?:(\d+):)?(\d+|~)', l[1])
                if m.group(2) == '~':
                    area = Area(tag=self, screen=m.group(1), ord=l[1], width=l[2],
                                height=l[3], frames=[])
                else:
                    area = Area(tag=self, screen=m.group(1) or 0,
                                ord=m.group(2), offset=l[2], width=l[3],
                                frames=[])
                areas.append(area)
                i = 0
            else:
                area.frames.append(
                    Frame(client=Client(l[1]), area=area, ord=i,
                          offset=l[2], height=l[3]))
                i += 1
        return areas

    def delete(self):
        id = self.id
        for a in self.index:
            for f in a.frames:
                if f.client.tags == id:
                    f.client.kill()
                else:
                    f.client.tags = '-%s' % id
        if self == Tag('sel'):
            Tags.instance.select(Tags.instance.next())

    def select(self, frame, stack=False):
        self['select'] = '%s %s' % (
            self.framespec(frame),
            stack and 'stack' or '')

    def send(self, src, dest, stack=False, cmd='send'):
        if isinstance(src, tuple):
            src = ' '.join(src)
        if isinstance(src, Frame):
            src = src.client
        if isinstance(src, Client):
            src = src._id or 'sel'

        if isinstance(dest, tuple):
            dest = ' '.join(dest)

        self[cmd] = '%s %s' % (src, dest)

    def swap(self, src, dest):
        self.send(src, dest, cmd='swap')
    
    def nudge(self, frame, dir, amount=None):
        frame = self.framespec(frame)
        self['nudge'] = '%s %s %s' % (frame, dir, str(amount or ''))
    def grow(self, frame, dir, amount=None):
        frame = self.framespec(frame)
        self['grow'] = '%s %s %s' % (frame, dir, str(amount or ''))

class Button(object):
    sides = {
        'left': 'lbar',
        'right': 'rbar',
    }
    def __init__(self, side, name, colors=None, label=None):
        self.side = side
        self.name = name
        self.base_path = self.sides[side]
        self.path = '%s/%s' % (self.base_path, self.name)
        self.file = None
        if colors or label:
            self.create(colors, label)

    def create(self, colors=None, label=None):
        def fail(resp, exc, tb):
            self.file = None
        if not self.file:
            self.file = client.create(self.path, ORDWR)
        if colors:
            self.file.awrite(self.getval(colors, label), offset=0, fail=fail)
        elif label:
            self.file.awrite(label, offset=24, fail=fail)

    def remove(self):
        if self.file:
            self.file.aremove()
            self.file = None

    def getval(self, colors=None, label=None):
        if label is None:
            label = self.label
        if colors is None and re.match(
            r'#[0-9a-f]{6} #[0-9a-f]{6} #[0-9a-f]{6}', label, re.I):
            colors = self.colors
        if not colors:
            return str(label)
        return ' '.join([Color(c).hex for c in colors] + [str(label)])

    colors = property(
        lambda self: self.file and
                     tuple(map(Color, self.file.read(offset=0).split(' ')[:3]))
                     or (),
        lambda self, val: self.create(colors=val))

    label = property(
        lambda self: self.file and self.file.read(offset=0).split(' ', 3)[3] or '',
        lambda self, val: self.create(label=val))

    @classmethod
    def all(cls, side):
        return (Button(side, s.name)
                for s in client.readdir(cls.sides[side])
                if s.name != 'sel')

class Colors(object):
    def __init__(self, foreground=None, background=None, border=None):
        vals = foreground, background, border
        self.vals = tuple(map(Color, vals))

    def __iter__(self):
        return iter(self.vals)
    def __list__(self):
        return list(self.vals)
    def __tuple__(self):
        return self.vals

    @classmethod
    def from_string(cls, val):
        return cls(*val.split(' '))

    def __getitem__(self, key):
        if isinstance(key, basestring):
            key = {'foreground': 0, 'background': 1, 'border': 2}[key]
        return self.vals[key]

    def __str__(self):
        return str(unicode(self))
    def __unicode__(self):
        return ' '.join(c.hex for c in self.vals)
    def __repr__(self):
        return 'Colors(%s, %s, %s)' % tuple(repr(c.rgb) for c in self.vals)

class Color(object):
    def __init__(self, colors):
        if isinstance(colors, Color):
            colors = colors.rgb
        elif isinstance(colors, basestring):
            match = re.match(r'^#(..)(..)(..)$', colors)
            colors = tuple(int(match.group(group), 16) for group in range(1, 4))
        def toint(val):
            if isinstance(val, float):
                val = int(255 * val)
            assert 0 <= val <= 255
            return val
        self.rgb = tuple(map(toint, colors))

    def __getitem__(self, key):
        if isinstance(key, basestring):
            key = {'red': 0, 'green': 1, 'blue': 2}[key]
        return self.rgb[key]

    @property
    def hex(self):
        return '#%02x%02x%02x' % self.rgb

    def __str__(self):
        return str(unicode(self))
    def __unicode__(self):
        return 'rgb(%d, %d, %d)' % self.rgb
    def __repr__(self):
        return 'Color(%s)' % repr(self.rgb)

class Rules(collections.MutableMapping):
    regex = re.compile(r'^\s*/(.*?)/\s*(?:->)?\s*(.*)$')

    def __get__(self, obj, cls):
        return self
    def __set__(self, obj, val):
        self.setitems(val)

    def __init__(self, path, rules=None):
        self.path = path
        if rules:
            self.setitems(rules)

    def __getitem__(self, key):
        for k, v in self.iteritems():
            if k == key:
                return v
        raise KeyError()
    def __setitem__(self, key, val):
        items = []
        for k, v in self.iteritems():
            if key == k:
                v = val
                key = None
            items.append((k, v))
        if key is not None:
            items.append((key, val))
        self.setitems(items)
    def __delitem__(self, key):
        self.setitems((k, v) for k, v in self.iteritems() if k != key)

    def __len__(self):
        return len(tuple(self.iteritems()))
    def __iter__(self):
        for k, v in self.iteritems():
            yield k
    def __list__(self):
        return list(iter(self))
    def __tuple__(self):
        return tuple(iter(self))

    def append(self, item):
        self.setitems(self + (item,))
    def __add__(self, items):
        return tuple(self.iteritems()) + tuple(items)

    def setitems(self, items):
        lines = []
        for k, v in items:
            assert '/' not in k and '\n' not in v
            lines.append('/%s/ -> %s' % (k, v))
        lines.append('')
        client.awrite(self.path, '\n'.join(lines))

    def iteritems(self):
        for line in client.readlines(self.path):
            match = self.regex.match(line)
            if match:
                yield match.groups()
    def items(self):
        return list(self.iteritems())

@apply
class wmii(Ctl):
    ctl_path = '/ctl'
    ctl_types = {
        'normcolors': (Colors.from_string, lambda c: str(Colors(*c))),
        'focuscolors': (Colors.from_string, lambda c: str(Colors(*c))),
        'border': (int, str),
    }

    clients = property(lambda self: Client.all())
    tags = property(lambda self: Tag.all())
    lbuttons = property(lambda self: Button.all('left'))
    rbuttons = property(lambda self: Button.all('right'))

    tagrules = Rules('/tagrules')
    colrules = Rules('/colrules')

class Tags(object):
    PREV = []
    NEXT = []

    def __init__(self, normcol=None, focuscol=None):
        self.ignore = set()
        self.tags = {}
        self.sel = None
        self.normcol = normcol
        self.focuscol = focuscol
        self.lastselect = datetime.now()
        for t in wmii.tags:
            self.add(t.id)
        for b in wmii.lbuttons:
            if b.name not in self.tags:
                b.remove()
        self.focus(Tag('sel').id)

        self.mru = [self.sel.id]
        self.idx = -1
        Tags.instance = self

    def add(self, tag):
        self.tags[tag] = Tag(tag)
        self.tags[tag].button = Button('left', tag, self.normcol or wmii.cache['normcolors'], tag)
    def delete(self, tag):
        self.tags.pop(tag).button.remove()

    def focus(self, tag):
        self.sel = self.tags[tag]
        self.sel.button.colors = self.focuscol or wmii.cache['focuscolors']
    def unfocus(self, tag):
        self.tags[tag].button.colors = self.normcol or wmii.cache['normcolors']

    def set_urgent(self, tag, urgent=True):
        self.tags[tag].button.label = urgent and '*' + tag or tag

    def next(self, reverse=False):
        tags = [t for t in wmii.tags if t.id not in self.ignore]
        tags.append(tags[0])
        if reverse:
            tags.reverse()
        for i in range(0, len(tags)):
            if tags[i] == self.sel:
                return tags[i+1]
        return self.sel

    def select(self, tag, take_client=None):
        def goto(tag):
            if take_client:
                sel = Tag('sel').id
                take_client.tags = '+%s' % tag
                wmii['view'] = tag
                if tag != sel:
                    take_client.tags = '-%s' % sel
            else:
                wmii['view'] = tag

        if tag is self.PREV:
            if self.sel.id not in self.ignore:
                self.idx -= 1
        elif tag is self.NEXT:
            self.idx += 1
        else:
            if isinstance(tag, Tag):
                tag = tag.id
            goto(tag)

            if tag not in self.ignore:
                if self.idx < -1:
                    self.mru = self.mru[:self.idx + 1]
                    self.idx = -1
                if self.mru and datetime.now() - self.lastselect < timedelta(seconds=.5):
                    self.mru[self.idx] = tag
                elif tag != self.mru[-1]:
                    self.mru.append(tag)
                    self.mru = self.mru[-10:]
                self.lastselect = datetime.now()
            return

        self.idx = constrain(-len(self.mru), -1, self.idx)
        goto(self.mru[self.idx])

# vim:se sts=4 sw=4 et:
