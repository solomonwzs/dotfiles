#!/usr/bin/python3
# -*- coding: utf-8 -*-
#
# @author    Solomon Ng <solomon.wzs@gmail.com>
# @date      2018-10-08
# @version   1.0
# @copyright MIT

from project.project import (
    find_cxx_header_files_dir,
    find,
)
import os
import vim


def set_cxx_gcc_options():
    if not find('compile_commands.json', os.path.curdir, n=1):
        inc = [f"-I{x}" for x in find_cxx_header_files_dir()]
        flags = ' ' + ' '.join(inc)

        for opt in ["g:ale_c_gcc_options", "g:ale_cpp_gcc_options"]:
            val = vim.eval(opt)
            vim.command(f"let {opt} = '{val} {flags}'")
