#!/usr/bin/python3
# -*- coding: utf-8 -*-
#
# @author   Solomon Ng <solomon.wzs@gmail.com>
# @date     2019-05-26
# @version  1.0
# @license  MIT

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
