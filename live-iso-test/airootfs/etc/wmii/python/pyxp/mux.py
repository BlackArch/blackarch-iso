# Derived from libmux, available in Plan 9 under /sys/src/libmux
# under the following terms:
#
# Copyright (C) 2003-2006 Russ Cox, Massachusetts Institute of Technology
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.

import sys
import traceback

from pyxp import fields
from pyxp.dial import dial
from threading import *
Condition = Condition().__class__

__all__ = 'Mux',

class Mux(object):
    def __init__(self, con, process, flush=None, mintag=0, maxtag=1<<16 - 1):
        self.queue = set()
        self.lock = RLock()
        self.rendez = Condition(self.lock)
        self.outlock = RLock()
        self.inlock = RLock()
        self.process = process
        self.flush = flush
        self.wait = {}
        self.free = set(range(mintag, maxtag))
        self.mintag = mintag
        self.maxtag = maxtag
        self.muxer = None

        if isinstance(con, basestring):
            con = dial(con)
        self.fd = con

        if self.fd is None:
            raise Exception("No connection")

    def mux(self, rpc):
        try:
            rpc.waiting = True
            self.lock.acquire()
            while self.muxer and self.muxer != rpc and rpc.data is None:
                rpc.wait()

            if rpc.data is None:
                assert not self.muxer or self.muxer is rpc
                self.muxer = rpc
                self.lock.release()
                try:
                    while rpc.data is None:
                        data = self.recv()
                        if data is None:
                            self.lock.acquire()
                            self.queue.remove(rpc)
                            raise Exception("unexpected eof")
                        self.dispatch(data)
                finally:
                    self.lock.acquire()
                    self.electmuxer()
        except Exception, e:
            traceback.print_exc(sys.stdout)
            if self.flush:
                self.flush(self, rpc.data)
            raise e
        finally:
            if self.lock._is_owned():
                self.lock.release()

        if rpc.async:
            if callable(rpc.async):
                rpc.async(self, rpc.data)
        else:
            return rpc.data

    def rpc(self, dat, async=None):
        rpc = self.newrpc(dat, async)
        if async:
            with self.lock:
                if self.muxer is None:
                    self.electmuxer()
        else:
            return self.mux(rpc)

    def electmuxer(self):
        async = None
        for rpc in self.queue:
            if self.muxer != rpc:
                if rpc.async:
                    async = rpc
                else:
                    self.muxer = rpc
                    rpc.notify()
                    return
        self.muxer = None
        if async:
            self.muxer = async
            t = Thread(target=self.mux, args=(async,))
            t.daemon = True
            t.start()

    def dispatch(self, dat):
        tag = dat.tag
        rpc = None
        with self.lock:
            rpc = self.wait.get(tag, None)
            if rpc is None or rpc not in self.queue:
                #print "bad rpc tag: %u (no one waiting on it)" % dat.tag
                return
            self.puttag(rpc)
            self.queue.remove(rpc)
            rpc.dispatch(dat)

    def gettag(self, r):
        tag = 0

        while not self.free:
            self.rendez.wait()

        tag = self.free.pop()

        if tag in self.wait:
            raise Exception("nwait botch")

        self.wait[tag] = r

        r.tag = tag
        r.orig.tag = r.tag
        return r.tag

    def puttag(self, rpc):
        if rpc.tag in self.wait:
            del self.wait[rpc.tag]
        self.free.add(rpc.tag)
        self.rendez.notify()

    def send(self, dat):
        data = ''.join(dat.marshall())
        n = self.fd.send(data)
        return n == len(data)
    def recv(self):
        try:
            with self.inlock:
                data = self.fd.recv(4)
                if data:
                    len = fields.Int.decoders[4](data, 0)
                    data += self.fd.recv(len - 4)
                    return self.process(data)
        except Exception, e:
            traceback.print_exc(sys.stdout)
            print repr(data)
            return None

    def newrpc(self, dat, async=None):
        rpc = Rpc(self, dat, async)
        tag = None

        with self.lock:
            self.gettag(rpc)
            self.queue.add(rpc)

        if rpc.tag >= 0 and self.send(dat):
            return rpc

        with self.lock:
            self.queue.remove(rpc)
            self.puttag(rpc)

class Rpc(Condition):
    def __init__(self, mux, data, async=None):
        super(Rpc, self).__init__(mux.lock)
        self.mux = mux
        self.orig = data
        self.data = None
        self.waiting = False
        self.async = async

    def dispatch(self, data=None):
        self.data = data
        if not self.async or self.waiting:
            self.notify()
        elif callable(self.async):
            Thread(target=self.async, args=(self.mux, data)).start()

# vim:se sts=4 sw=4 et:
