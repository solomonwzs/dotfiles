#!/usr/bin/python3
# -*- coding: utf-8 -*-
#
# @author   Solomon Ng <solomon.wzs@gmail.com>
# @date     2018-11-20
# @version  1.0
# @license  MIT

import os
import sys

vimpy = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.append(vimpy)

from common import system_command


def get_go_env():
    output = system_command("go env").strip()
    kvlist = output.split("\n")
    env = {}
    for kv in kvlist:
        arr = kv.split("=", 1)
        if len(arr) == 2:
            env[arr[0]] = arr[1][1:-1]
    return env


def compiled_packages():
    pass


def get_go_path():
    gopath = os.environ.get("GOPATH", "")
    return gopath.split(":")


if __name__ == "__main__":
    print(get_go_env())
