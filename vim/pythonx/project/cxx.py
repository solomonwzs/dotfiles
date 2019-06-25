#!/usr/bin/python3
# -*- coding: utf-8 -*-
#
# @author   Solomon Ng <solomon.wzs@gmail.com>
# @date     2019-05-25
# @version  1.0
# @license  MIT

import sys
import os

vimpy = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.append(vimpy)

from common import system_command
from typing import List
import re

CXX_HEADER_EXT = {'.h', '.hh', '.hpp', '.hxx'}
CXX_FLAGS_FILE_NAME = 'compile_flags.txt'


def get_system_type() -> str:
    t = system_command("uname")
    return t.strip().lower()


def get_system_cxx_version() -> str:
    st = get_system_type()
    if st == "linux":
        vgcc = system_command("gcc --version")
        g = re.findall(r"gcc \(GCC\) (.*)\n.*", vgcc)
        return g[0]
    elif st == "darwin":
        return ""
    else:
        return ""


def get_system_cxx_header_paths() -> List[str]:
    cver = get_system_cxx_version()
    paths = [
        os.path.join("/usr/include/c++", cver),
        os.path.join("/usr/include/c++", cver, "x86_64-pc-linux-gnu"),
        os.path.join("/usr/include/c++", cver, "backward"),
    ]
    return [x for x in paths if os.path.isdir(x)]


def find_cxx_header_files_dir(path='.'):
    result = []
    for root, dirs, files in os.walk(path):
        for name in files:
            extension = os.path.splitext(name)[1]
            if extension in CXX_HEADER_EXT:
                result.append(root)
                break
    return result


if __name__ == "__main__":
    res = get_system_cxx_header_paths()
    print(res)
