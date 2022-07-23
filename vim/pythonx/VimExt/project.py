#!/usr/bin/python3
# -*- coding: utf-8 -*-
#
# @author   Solomon Ng <solomon.wzs@gmail.com>
# @date     2022-07-24
# @version  1.0
# @license  MIT

from .helper import system_command
from subprocess import PIPE, Popen
from typing import List
import logging
import os
import re

logging.basicConfig(
    format="\033[3;32m(%(levelname).1s) %(asctime)s [%(filename)s:%(lineno)s - %(funcName)s]\033[0m %(message)s",
    level=logging.DEBUG,
)

CXX_HEADER_EXT = {".h", ".hh", ".hpp", ".hxx"}
CXX_FLAGS_FILE_NAME = "compile_flags.txt"

VIM_HOME = os.path.dirname(
    os.path.dirname(os.path.dirname(os.path.realpath(__file__)))
)


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


def find_cxx_header_files_dir(path="."):
    result = []
    for root, dirs, files in os.walk(path):
        for name in files:
            extension = os.path.splitext(name)[1]
            if extension in CXX_HEADER_EXT:
                result.append(root)
                break
    return result


def get_golang_env():
    output = system_command("go env").strip()
    kvlist = output.split("\n")
    env = {}
    for kv in kvlist:
        arr = kv.split("=", 1)
        if len(arr) == 2:
            env[arr[0]] = arr[1][1:-1]
    return env


def get_golang_path():
    gopath = os.environ.get("GOPATH", "")
    return gopath.split(":")


def get_makefile_variable(makefiles, var):
    var_mk = os.path.join(VIM_HOME, "other/makefile/variable.mk")
    cmd = ["make"]
    for f in makefiles:
        cmd += ["-f", f]
    cmd += ["-f", var_mk, "debug-var-%s" % var]
    p = Popen(" ".join(cmd), shell=True, stdout=PIPE, stderr=PIPE)
    output, err = p.communicate()

    if p.returncode != 0:
        return ""
    else:
        return output.decode("utf8")


def get_file_lines(filename):
    flags = []
    with open(filename, "r") as fd:
        line = fd.readline()
        while line:
            flags.append(line.strip())
            line = fd.readline()
    return flags


def get_cxx_gcc_options() -> dict[str, str]:
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

    d: dict[str, str] = {}
    if cflags != "":
        d["ale_c_cc_options"] = cflags
    if cxxflags != "":
        d["ale_cpp_cc_options"] = cxxflags
    if flags != "":
        d["ale_c_cc_options"] = flags
        d["ale_cpp_cc_options"] = flags
    return d


if __name__ == "__main__":
    logging.debug(VIM_HOME)
    logging.debug(get_cxx_gcc_options())
