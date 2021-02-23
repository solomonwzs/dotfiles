#!/usr/bin/python3
# -*- coding: utf-8 -*-
#
# @author   Solomon Ng <solomon.wzs@gmail.com>
# @date     2019-05-26
# @version  1.0
# @license  MIT

import base64
import re
import subprocess

def system_command(cmd: str) -> str:
    """
    Execute system command.
    """
    p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE,
                         stderr=subprocess.PIPE)
    output, err = p.communicate()
    if len(err) != 0:
        return err.decode("utf8")
    else:
        return output.decode("utf8")

def utf8_str_width(s: str) -> int:
    """
    Get utf-8 string character width.
    """
    width = 0
    i = 0
    buf = s.encode('utf8')
    while i < len(buf):
        byte = buf[i]
        if (byte <= 127):
            width += 1
            i += 1
        else:
            width += 2
            if (byte & 0xe0) == 0xc0:
                i += 2
            elif (byte & 0xf0) == 0xe0:
                i += 3
            elif (byte & 0xf8) == 0xf0:
                i += 4
            else:
                break
    return width

def decode_utf8_str(s: str) -> (bool, str):
    res = re.findall(r'\\x(..)', s)
    try:
        b = bytes(map(lambda x: int(x, 16), res))
        return True, b.decode('utf8')
    except Exception as err:
        return False, str(err)

def swict_hex(matchobj) -> bytes:
    str_hex = matchobj.group(1)
    i = int(str_hex, base=16)
    return bytes([i])

def decode_mime_encode_str(s: str) -> (bool, str):
    res = re.findall(r'=\?(.*)\?([BbQq])\?(.*)\?=', s)
    if len(res) == 0:
        return False, 'Error format'

    blist = []
    for s in res:
        (charset, encoding, text) = s
        if encoding == 'B' or encoding == 'b':
            blist.append((charset, base64.b64decode(text)))
        else:
            enb = re.sub(b'=([A-F0-9]{2})', swict_hex, text.encode('ascii'))
            blist.append((charset, enb))

    if len(blist) == 0:
        return True, ''

    (charset, b) = blist[0]
    text = ''
    for i in range(1, len(blist)):
        if blist[i][0] == charset:
            b += blist[i][1]
        else:
            text += b.decode(charset)
            (charset, b) = blist[i]
    text += b.decode(charset)
    return True, text
