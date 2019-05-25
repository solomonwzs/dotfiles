#!/usr/bin/python3
# -*- coding: utf-8 -*-
#
# @author    Solomon Ng <solomon.wzs@gmail.com>
# @date      2018-10-08
# @version   1.0
# @copyright MIT

from project.project import (
    get_makefile_variable,
    get_file_lines,
)
from project.cxx import (
    CXX_FLAGS_FILE_NAME,
)
import os
import vim


def set_cxx_gcc_options():
    flags = ''

    makefile = os.path.join(os.getcwd(), 'Makefile')
    if os.path.exists(makefile):
        flags = get_makefile_variable([makefile], 'CFLAGS')

    cflags_file = os.path.join(os.getcwd(), CXX_FLAGS_FILE_NAME)
    if os.path.exists(cflags_file):
        fs = get_file_lines(cflags_file)
        flags += ' ' + ' '.join(fs)

    flags = flags.strip()
    if flags != '':
        b = vim.vars
        b['ale_c_gcc_options'] = flags
        b['ale_cpp_gcc_options'] = flags
