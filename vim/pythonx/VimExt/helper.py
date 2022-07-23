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

logging.basicConfig(
    format="\033[3;32m(%(levelname).1s) %(asctime)s [%(filename)s:%(lineno)s - %(funcName)s]\033[0m %(message)s",
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


if __name__ == "__main__":
    logging.debug(
        parse_filepath("/home/solomon/dotfiles/vim/pythonx/VimExt/helper.py")
    )
