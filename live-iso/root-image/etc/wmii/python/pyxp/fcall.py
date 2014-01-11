from pyxp.messages import MessageBase, Message
from pyxp.fields import *
from types import Qid, Stat

__all__ = 'Fcall',

NO_FID = 1<<32 - 1
MAX_WELEM = 16

class FcallBase(MessageBase):
    idx = 99
    def __new__(cls, name, bases, attrs):
        new_cls = super(FcallBase, cls).__new__(cls, name, bases, attrs)
        new_cls.type = FcallBase.idx
        if new_cls.type > 99:
            new_cls.types[new_cls.type] = new_cls
        FcallBase.idx += 1
        return new_cls

class Fcall(Message):
    __metaclass__ = FcallBase
    types = {}

    def response(self, *args, **kwargs):
        assert self.type % 2 == 0, "No respense type for response fcalls"
        kwargs['tag'] = self.tag
        return self.types[self.type + 1]()

    @classmethod
    def unmarshall(cls, data, offset=0):
        res = super(Fcall, cls).unmarshall(data, offset)
        if cls.type < 100:
            res = cls.types[res[1].type].unmarshall(data, offset)
        return res

    size = Size(4, 4)
    type = Int(1)
    tag  = Int(2)

class Tversion(Fcall):
    msize   = Int(4)
    version = String()
class Rversion(Fcall):
    msize   = Int(4)
    version = String()

class Tauth(Fcall):
    afid  = Int(4)
    uname = String()
    aname = String()
class Rauth(Fcall):
    aqid  = Qid.field()

class Tattach(Fcall):
    fid   = Int(4)
    afid  = Int(4)
    uname = String()
    aname = String()
class Rattach(Fcall):
    qid   = Qid.field()

class Terror(Fcall):
    def __init__(self):
        raise Exception("Illegal 9P tag 'Terror' encountered")
class Rerror(Fcall):
    ename = String()

class Tflush(Fcall):
    oldtag = Int(2)
class Rflush(Fcall):
    pass

class Twalk(Fcall):
    fid    = Int(4)
    newfid = Int(4)
    wname  = Array(2, String())
class Rwalk(Fcall):
    wqid   = Array(2, Qid.field())

class Topen(Fcall):
    fid    = Int(4)
    mode   = Int(1)
class Ropen(Fcall):
    qid    = Qid.field()
    iounit = Int(4)

class Tcreate(Fcall):
    fid    = Int(4)
    name   = String()
    perm   = Int(4)
    mode   = Int(1)
class Rcreate(Fcall):
    qid    = Qid.field()
    iounit = Int(4)

class Tread(Fcall):
    fid    = Int(4)
    offset = Int(8)
    count  = Int(4)
class Rread(Fcall):
    data   = Data(4)

class Twrite(Fcall):
    fid    = Int(4)
    offset = Int(8)
    data   = Data(4)
class Rwrite(Fcall):
    count  = Int(4)

class Tclunk(Fcall):
    fid    = Int(4)
class Rclunk(Fcall):
    pass

class Tremove(Tclunk):
    pass
class Rremove(Fcall):
    pass

class Tstat(Tclunk):
    pass
class Rstat(Fcall):
    sstat = Size(2)
    stat  = Stat.field()

class Twstat(Rstat):
    pass
class Rwstat(Fcall):
    pass

# vim:se sts=4 sw=4 et:
