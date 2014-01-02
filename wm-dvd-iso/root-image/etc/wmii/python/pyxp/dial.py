from socket import *

__all__ = 'dial',

def dial_unix(address):
    sock = socket(AF_UNIX, SOCK_STREAM, 0)
    sock.connect(address)
    return sock

def dial_tcp(host):
    host = host.split('!')
    if len(host) != 2:
        return
    host, port = host

    res = getaddrinfo(host, port, AF_INET, SOCK_STREAM, 0, AI_PASSIVE)
    for family, socktype, protocol, name, addr in res:
        try:
            sock = socket(family, socktype, protocol)
            sock.connect(addr)
            return sock
        except error:
            if sock:
                sock.close()

def dial(address):
    proto, address = address.split('!', 1)
    if proto == 'unix':
        return dial_unix(address)
    elif proto == 'tcp':
        return dial_tcp(address)
    else:
        raise Exception('invalid protocol')

# vim:se sts=4 sw=4 et:
