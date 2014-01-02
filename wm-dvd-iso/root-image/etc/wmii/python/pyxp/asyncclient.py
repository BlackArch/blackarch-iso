from pyxp import client, fcall
from pyxp.client import *

def awithfile(*oargs, **okwargs):
    def wrapper(fn):
        def next(self, path, *args, **kwargs):
            def next(file, exc, tb):
                fn(self, (file, exc, tb), *args, **kwargs)
            self.aopen(path, next, *oargs, **okwargs)
        return next
    return wrapper
def wrap_callback(fn, file):
    def callback(data, exc, tb):
        file.close()
        Client.respond(fn, data, exc, tb)
    return callback

class Client(client.Client):
    ROOT_FID = 0

    def _awalk(self, path, callback, fail=None):
        ctxt = dict(path=path, fid=self._getfid(), ofid=ROOT_FID)
        def next(resp=None, exc=None, tb=None):
            if exc and ctxt['ofid'] != ROOT_FID:
                self._aclunk(ctxt['fid'])
            if not ctxt['path'] and resp or exc:
                if exc and fail:
                    return self.respond(fail, None, exc, tb)
                return self.respond(callback, ctxt['fid'], exc, tb)
            wname = ctxt['path'][:fcall.MAX_WELEM]
            ofid = ctxt['ofid']
            ctxt['path'] = ctxt['path'][fcall.MAX_WELEM:]
            if resp:
                ctxt['ofid'] = ctxt['fid']
            self._dorpc(fcall.Twalk(fid=ofid,
                                   newfid=ctxt['fid'],
                                   wname=wname),
                       next)
        next()

    _file = property(lambda self: File)
    def _aopen(self, path, mode, open, callback, fail=None, origpath=None):
        resp = None
        def next(fid, exc, tb):
            def next(resp, exc, tb):
                def cleanup():
                    self._clunk(fid)
                file = self._file(self, origpath or '/'.join(path), resp, fid, mode, cleanup)
                self.respond(callback, file)
            self._dorpc(open(fid), next, fail or callback)
        self._awalk(path, next, fail or callback)

    def aopen(self, path, callback=True, fail=None, mode=OREAD):
        assert callable(callback)
        path = self._splitpath(path)
        def open(fid):
            return fcall.Topen(fid=fid, mode=mode)
        return self._aopen(path, mode, open, fail or callback)

    def acreate(self, path, callback=True, fail=None, mode=OREAD, perm=0):
        path = self._splitpath(path)
        name = path.pop()
        def open(fid):
            return fcall.Tcreate(fid=fid, mode=mode, name=name, perm=perm)
        if not callable(callback):
            def callback(resp, exc, tb):
                if resp:
                    resp.close()
        return self._aopen(path, mode, open, callback, fail,
                           origpath='/'.join(path + [name]))

    def aremove(self, path, callback=True, fail=None):
        path = self._splitpath(path)
        def next(fid, exc, tb):
            self._dorpc(fcall.Tremove(fid=fid), callback, fail)
        self._awalk(path, next, callback, fail)

    def astat(self, path, callback, fail = None):
        path = self._splitpath(path)
        def next(fid, exc, tb):
            def next(resp, exc, tb):
                callback(resp.stat, exc, tb)
            self._dorpc(fcall.Tstat(fid=fid), next, callback)

    @awithfile()
    def aread(self, (file, exc, tb), callback, *args, **kwargs):
        if exc:
            callback(file, exc, tb)
        else:
            file.aread(wrap_callback(callback, file), *args, **kwargs)
    @awithfile(mode=OWRITE)
    def awrite(self, (file, exc, tb), data, callback=True, *args, **kwargs):
        if exc:
            self.respond(callback, file, exc, tb)
        else:
            file.awrite(data, wrap_callback(callback, file), *args, **kwargs)
    @awithfile()
    def areadlines(self, (file, exc, tb), fn):
        def callback(resp):
            if resp is None:
                file.close()
            if fn(resp) is False:
                file.close()
                return False
        if exc:
            callback(None)
        else:
            file.sreadlines(callback)

class File(client.File):
    @staticmethod
    def respond(callback, data, exc=None, tb=None):
        if callable(callback):
            callback(data, exc, tb)

    def stat(self, callback):
        def next(resp, exc, tb):
            callback(resp.stat, exc, tb)
        resp = self._dorpc(fcall.Tstat(), next, callback)

    def aread(self, callback, fail=None, count=None, offset=None, buf=''):
        ctxt = dict(res=[], count=self.iounit, offset=self.offset)
        if count is not None:
            ctxt['count'] = count
        if offset is not None:
            ctxt['offset'] = offset
        def next(resp=None, exc=None, tb=None):
            if resp and resp.data:
                ctxt['res'].append(resp.data)
                ctxt['offset'] += len(resp.data)
            if ctxt['count'] == 0:
                if offset is None:
                    self.offset = ctxt['offset']
                return callback(''.join(ctxt['res']), exc, tb)

            n = min(ctxt['count'], self.iounit)
            ctxt['count'] -= n

            self._dorpc(fcall.Tread(offset=ctxt['offset'], count=n),
                       next, fail or callback)
        next()

    def areadlines(self, callback):
        ctxt = dict(last=None)
        def next(data, exc, tb):
            res = True
            if data:
                lines = data.split('\n')
                if ctxt['last']:
                    lines[0] = ctxt['last'] + lines[0]
                for i in range(0, len(lines) - 1):
                    res = callback(lines[i])
                    if res is False:
                        break
                ctxt['last'] = lines[-1]
                if res is not False:
                    self.aread(next)
            else:
                if ctxt['last']:
                    callback(ctxt['last'])
                callback(None)
        self.aread(next)

    def awrite(self, data, callback=True, fail=None, offset=None):
        ctxt = dict(offset=self.offset, off=0)
        if offset is not None:
            ctxt['offset'] = offset
        def next(resp=None, exc=None, tb=None):
            if resp:
                ctxt['off'] += resp.count
                ctxt['offset'] += resp.count
            if ctxt['off'] < len(data) or not (exc or resp):
                n = min(len(data), self.iounit)

                self._dorpc(fcall.Twrite(offset=ctxt['offset'],
                                        data=data[ctxt['off']:ctxt['off']+n]),
                           next, fail or callback)
            else:
                if offset is None:
                    self.offset = ctxt['offset']
                self.respond(callback, ctxt['off'], exc, tb)
        next()

    def aremove(self, callback=True, fail=None):
        def next(resp, exc, tb):
            self.close()
            if exc and fail:
                self.respond(fail, resp and True, exc, tb)
            else:
                self.respond(callback, resp and True, exc, tb)
        self._dorpc(fcall.Tremove(), next)

# vim:se sts=4 sw=4 et:
