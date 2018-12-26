#!/usr/bin/python3
# -*- coding: utf-8 -*-
#
# @author    Solomon Ng <solomon.wzs@gmail.com>
# @date      2018-10-08
# @version   1.0
# @copyright MIT

from project.project import get_makefile_variable
import os
import vim


def set_cxx_gcc_options():
    makefile = os.path.join(os.getcwd(), 'Makefile')
    if not os.path.exists(makefile):
        return
    flags = get_makefile_variable([makefile], 'CFLAGS')
    if flags != '':
        b = vim.vars
        b['ale_c_gcc_options'] = flags
        b['ale_cpp_gcc_options'] = flags
