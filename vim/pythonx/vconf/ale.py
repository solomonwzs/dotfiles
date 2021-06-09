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
    flags = ""
    cflags = ""
    cxxflags = ""

    makefile = os.path.join(os.getcwd(), "Makefile")
    if os.path.exists(makefile):
        cflags = get_makefile_variable([makefile], "CFLAGS")
        cxxflags = get_makefile_variable([makefile], "CXXFLAGS")
        flags = get_makefile_variable([makefile], "CPPFLAGS")

    cflags_file = os.path.join(os.getcwd(), CXX_FLAGS_FILE_NAME)
    if os.path.exists(cflags_file):
        fs = get_file_lines(cflags_file)
        flags += " " + " ".join(fs)

    flags = flags.strip()
    cflags = cflags.strip()
    cxxflags = cxxflags.strip()

    b = vim.vars
    if cflags != "":
        b["ale_c_cc_options"] = cflags
    if cxxflags != "":
        b["ale_cpp_cc_options"] = cxxflags
    if flags != "":
        b["ale_c_cc_options"] = flags
        b["ale_cpp_cc_options"] = flags
