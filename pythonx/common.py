#!/usr/bin/python3
# -*- coding: utf-8 -*-
#
# @author   Solomon Ng <solomon.wzs@gmail.com>
# @date     2019-05-26
# @version  1.0
# @license  MIT

import subprocess


def system_command(cmd: str) -> str:
    p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE,
                         stderr=subprocess.PIPE)
    output, err = p.communicate()
    if len(err) != 0:
        return err.decode("utf8")
    else:
        return output.decode("utf8")
