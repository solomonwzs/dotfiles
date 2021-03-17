#!/usr/bin/python3
# -*- coding: utf-8 -*-
#
# @author   Solomon Ng <solomon.wzs@gmail.com>
# @date     2021-03-17
# @version  1.0
# @license  MIT

import fcntl
import json
import os
import pathlib
import sys
sys.path.append(pathlib.Path(__file__).parent.absolute())

import CocExt

if __name__ == "__main__":
    fcntl.fcntl(sys.stdin, fcntl.F_SETFL, os.O_NONBLOCK)
    msg = json.loads(sys.stdin.read())
    module = getattr(CocExt, msg.get('module'))
    function = getattr(module, msg.get('func'))
    argv = msg.get('argv')
    function(*argv)
