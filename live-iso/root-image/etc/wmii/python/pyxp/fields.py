from datetime import datetime
import operator

class Field(object):
    idx = 0

    def __init__(self):
        Field.idx += 1
        self.id = Field.idx

    def repr(self):
        return self.__class__.__name__

    def __repr__(self):
        if hasattr(self, 'name'):
            return '<Field %s "%s">' % (self.repr(), self.name)
        return super(Field, self).__repr__()

class Int(Field):
    encoders = {}
    decoders = {}
    @classmethod
    def encoder(cls, n):
        if n not in cls.encoders:
            exec ('def enc(n):\n' +
                  '    assert n == n & 0x%s, "Arithmetic overflow"\n' % ('ff' * n) +
                  '    return "".join((' + ','.join(
                      'chr((n >> %d) & 0xff)' % (i * 8)
                      for i in range(0, n)) + ',))\n')
            cls.encoders[n] = enc
        return cls.encoders[n]
    @classmethod
    def decoder(cls, n):
        if n not in cls.decoders:
            cls.decoders[n] = eval('lambda data, offset: ' + '|'.join(
                'ord(data[offset + %d]) << %d' % (i, i * 8)
                for i in range(0, n)))
        return cls.decoders[n]

    def __init__(self, size):
        super(Int, self).__init__()
        self.size = size
        self.encode = self.encoder(size)
        self.decode = self.decoder(size)
        if self.__class__ == Int:
            self.marshall = self.encode

    def unmarshall(self, data, offset):
        return self.size, self.decode(data, offset)
    def marshall(self, val):
        return self.encode(val)

    def repr(self):
        return '%s(%d)' % (self.__class__.__name__, self.size)

class Size(Int):
    def __init__(self, size, extra=0):
        super(Size, self).__init__(size)
        self.extra = extra

    def marshall(self, val):
        return lambda vals, i: self.encode(
            reduce(lambda n, i: n + len(vals[i]),
                   range(i + 1, len(vals)),
                   self.extra))

class Date(Int):
    def __init__(self):
        super(Date, self).__init__(4)

    def unmarshall(self, data, offset):
        val = self.decode(data, offset)
        return 4, datetime.fromtimestamp(val)
    def marshall(self, val):
        return self.encode(int(val.strftime('%s')))

class Data(Int):
    def __init__(self, size=2):
        super(Data, self).__init__(size)
    def unmarshall(self, data, offset):
        n = self.decode(data, offset)
        offset += self.size
        assert offset + n <= len(data), "String too long to unpack"
        return self.size + n, data[offset:offset + n]
    def marshall(self, val):
        if isinstance(val, unicode):
            val = val.encode('UTF-8')
        return [self.encode(len(val)), val]

# Note: Py3K strings are Unicode by default. They can't store binary
#       data.
class String(Data):
    def unmarshall(self, data, offset):
        off, val = super(String, self).unmarshall(data, offset)
        return off, val.decode('UTF-8')
    def marshall(self, val):
        if isinstance(val, str):
            # Check for valid UTF-8
            str.decode('UTF-8')
        else:
            val = val.encode('UTF-8')
        return super(String, self).marshall(val)

class Array(Int):
    def __init__(self, size, spec):
        super(Array, self).__init__(size)
        self.spec = spec

    def unmarshall(self, data, offset):
        start = offset
        n = self.decode(data, offset)
        offset += self.size
        res = []
        for i in range(0, n):
            size, val = self.spec.unmarshall(data, offset)
            if isinstance(val, list):
                res += val
            else:
                res.append(val)
            offset += size
        return offset - start, res
    def marshall(self, vals):
        res = [self.encode(len(vals))]
        for val in vals:
            val = self.spec.marshall(val)
            if isinstance(val, list):
                res += val
            else:
                res.append(val)
        return res

# vim:se sts=4 sw=4 et:
