from pyxp.fields import *

class MessageBase(type):
    idx = 0

    def __new__(cls, name, bases, attrs):
        fields = []
        fieldmap = {}
        for k, v in attrs.items():
            if isinstance(v, Field):
                attrs[k] = None
                fields.append(v)
                fieldmap[k] = v
                v.name = k
        fields.sort(lambda a, b: cmp(a.id, b.id))

        new_cls = super(MessageBase, cls).__new__(cls, name, bases, attrs)

        map = getattr(new_cls, 'fieldmap', {})
        map.update(fieldmap)
        new_cls.fields = getattr(new_cls, 'fields', ()) + tuple(fields)
        new_cls.fieldmap = map
        for f in fields:
            f.message = new_cls
        return new_cls

class Message(object):
    __metaclass__ = MessageBase
    def __init__(self, *args, **kwargs):
        if args:
            args = dict(zip([f.name for f in self.fields], args))
            args.update(kwargs)
            kwargs = args;
        for k, v in kwargs.iteritems():
            assert k in self.fieldmap, "Invalid keyword argument"
            setattr(self, k, v)

    @classmethod
    def field(cls):
        class MessageField(Field):
            def repr(self):
                return cls.__name__
            def unmarshall(self, data, offset):
                return cls.unmarshall(data, offset)
            def marshall(self, val):
                return val.marshall()
        return MessageField()

    @classmethod
    def unmarshall(cls, data, offset=0):
        vals = {}
        start = offset
        for field in cls.fields:
            size, val = field.unmarshall(data, offset)
            offset += size
            vals[field.name] = val
        return offset - start, cls(**vals)
    def marshall(self):
        res = []
        callbacks = []
        for field in self.fields:
            val = field.marshall(getattr(self, field.name, None))
            if callable(val):
                callbacks.append((val, len(res)))
            if isinstance(val, list):
                res += val
            else:
                res.append(val)
        for fn, i in reversed(callbacks):
            res[i] = fn(res, i)
        return res

# vim:se sts=4 sw=4 et:
