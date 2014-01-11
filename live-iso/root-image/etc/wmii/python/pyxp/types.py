from pyxp.messages import Message
from pyxp.fields import *

__all__ = 'Qid', 'Stat'
          
class Qid(Message):
    QTFILE    = 0x00
    QTLINK    = 0x01
    QTSYMLINK = 0x02
    QTTMP     = 0x04
    QTAUTH    = 0x08
    QTMOUNT   = 0x10
    QTEXCL    = 0x20
    QTAPPEND  = 0x40
    QTDIR     = 0x80

    type    = Int(1)
    version = Int(4)
    path    = Int(8)

class Stat(Message):
    DMDIR       = 0x80000000
    DMAPPEND    = 0x40000000
    DMEXCL      = 0x20000000
    DMMOUNT     = 0x10000000
    DMAUTH      = 0x08000000
    DMTMP       = 0x04000000
    DMSYMLINK   = 0x02000000
    DMDEVICE    = 0x00800000
    DMNAMEDPIPE = 0x00200000
    DMSOCKET    = 0x00100000
    DMSETUID    = 0x00080000
    DMSETGID    = 0x00040000

    @classmethod
    def unmarshall_list(cls, data, offset=0):
        while offset < len(data):
            n, stat = cls.unmarshall(data, offset)
            offset += n
            yield stat

    size   = Size(2)
    type   = Int(2)
    dev    = Int(4)
    qid    = Qid.field()
    mode   = Int(4)
    atime  = Date()
    mtime  = Date()
    length = Int(8)
    name   = String()
    uid    = String()
    gid    = String()
    muid   = String()

# vim:se sts=4 sw=4 et:
