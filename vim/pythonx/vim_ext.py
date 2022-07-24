#!/usr/bin/python3
# -*- coding: utf-8 -*-
#
# @author   Solomon Ng <solomon.wzs@gmail.com>
# @date     2022-07-23
# @version  1.0
# @license  MIT

from typing import Any
import VimExt
import json
import logging
from logging.handlers import RotatingFileHandler


rfh = RotatingFileHandler(
    filename="/tmp/vim_ext.log",
    mode="a",
    maxBytes=32 * 1024 * 1024,
    backupCount=2,
    encoding=None,
)

logging.basicConfig(
        format="\033[3;32m(%(levelname).1s) %(asctime)s <%(process)d> [%(filename)s:%(funcName)s:%(lineno)s]\033[0m %(message)s",
    datefmt="%y-%m-%d %H:%M:%S",
    level=logging.INFO,
    force=True,
    handlers=[rfh],
)


def call(m: str, f: str, a: Any) -> str:
    try:
        module = getattr(VimExt, m)
        function = getattr(module, f)
        res = function() if a is None else function(a)
        return json.dumps({"error": 0, "data": res})
    except Exception as e:
        return json.dumps({"error": -1, "msg": str(e)})


if __name__ == "__main__":
    print(call("a", "b", "c"))
