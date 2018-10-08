#!/usr/bin/python3
# -*- coding: utf-8 -*-
#
# @author    Solomon Ng <solomon.wzs@gmail.com>
# @date      2018-10-08
# @version   1.0
# @copyright MIT

from project.project import find_cxx_header_files_dir
import vim


def set_cxx_gcc_opts():
    inc = [f"-I{x}" for x in find_cxx_header_files_dir()]
    flag = ' ' + ' '.join(inc)

    vim.command(f"let g:ale_c_gcc_options = '-Wall -O2 -std=c99 {flag}'")
    vim.command(f"let g:ale_cpp_gcc_options = '-Wall -O2 -std=c++14 {flag}'")
