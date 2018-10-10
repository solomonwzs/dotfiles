#!/usr/bin/python3
# -*- coding: utf-8 -*-
#
# @author   Solomon Ng <solomon.wzs@gmail.com>
# @date     2018-10-10
# @version  1.0
# @license  MIT

import fnmatch
import os

cxx_headers_ext = {'.h', '.hh', '.hpp', '.hxx'}


def find(pattern, path, n=0):
    result = []
    for root, dirs, files in os.walk(path):
        for name in files:
            if fnmatch.fnmatch(name, pattern):
                result.append(os.path.join(root, name))
                if n > 0 and len(result) == n:
                    return result
    return result


def find_cxx_header_files_dir(path='.'):
    result = []
    for root, dirs, files in os.walk(path):
        for name in files:
            extension = os.path.splitext(name)[1]
            if extension in cxx_headers_ext:
                result.append(root)
                break
    return result
