#!/usr/bin/python3
# -*- coding: utf-8 -*-
#
# @author   Solomon Ng <solomon.wzs@gmail.com>
# @date     2022-07-24
# @version  1.0
# @license  MIT

import subprocess
import os
import logging
import re

logging.basicConfig(
    format="\033[3;32m(%(levelname).1s) %(asctime)s <%(process)d> [%(filename)s:%(funcName)s:%(lineno)s]\033[0m %(message)s",
    level=logging.DEBUG,
)


def system_command(cmd: str) -> str:
    """
    Execute system command.
    """
    p = subprocess.Popen(
        cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE
    )
    output, err = p.communicate()
    if len(err) != 0:
        return err.decode("utf8")
    else:
        return output.decode("utf8")


def parse_filepath(filepath: str) -> dict:
    dirname = os.path.dirname(filepath)
    fname = os.path.basename(filepath)
    _, ext = os.path.splitext(filepath)
    if len(ext) > 0:
        ext = ext[1:]
    return {"name": fname, "ext": ext, "dir": dirname}


def parse_highlight_info(s: str):
    lines = [re.split(r"\s+", x) for x in s.split("\n") if len(x) > 0]

    group_name = ""
    desc = ""
    last_set_file = ""
    lineno = 0
    infos = []
    max_glen = 0
    for arr in lines:
        if len(arr) > 0 and arr[0] != "":
            if group_name != "":
                infos.append((group_name, desc, last_set_file, lineno))
            group_name = arr[0]
            if len(arr) > 2:
                desc = " ".join(arr[2:])
            else:
                desc = ""
            last_set_file = ""
            lineno = 0
        elif len(arr) == 7 and arr[0] == "" and arr[1] == "Last":
            last_set_file = arr[4]
            lineno = int(arr[6])
        elif len(arr) > 1 and arr[0] == "":
            if desc != "":
                desc += ", "
            desc += " ".join(arr[1:])
    if group_name != "":
        infos.append((group_name, desc, last_set_file, lineno))
    out = []
    for i in infos:
        out.append(f"{i[0]}\t{i[1]}")
    return out


if __name__ == "__main__":
    logging.info(
        parse_filepath("/home/solomon/dotfiles/vim/pythonx/VimExt/helper.py")
    )
