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
