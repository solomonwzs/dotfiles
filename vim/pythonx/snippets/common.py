#!/usr/bin/python3
# -*- coding: utf-8 -*-
#
# @author   Solomon Ng <solomon.wzs@gmail.com>
# @date     2018-10-10
# @version  1.0
# @license  GPL-2.0+

from datetime import datetime
import os


def strtoday():
    return datetime.today().strftime("%Y-%m-%d")


def document_name(path):
    d = os.path.dirname(path)
    (_, name) = os.path.split(d)
    return name
