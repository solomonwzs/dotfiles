#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# @author   Solomon Ng <solomon.wzs@gmail.com>
# @date     2023-12-01
# @version  1.0
# @license  GPL-2.0+

import os
import re
import csv
import time
import gmail_oauth2_token


def parse_my_conf():
    with open(f"{os.path.expanduser('~')}/.my_conf.sh") as fd:
        cont = fd.read().strip()
    var_declarations = re.findall(
        r"^[a-zA-Z0-9_]+=.*$", cont, flags=re.MULTILINE
    )
    reader = csv.reader(var_declarations, delimiter="=")
    return dict(reader)


def get_gmail_oauth2_token():
    conf = parse_my_conf()
    client_id = conf.get("MY_GMAIL_CLIENT_ID")
    client_secret = conf.get("MY_GMAIL_CLIENT_SECRET")
    rtoken = conf.get("MY_GMAIL_REFRESH_TOKEN")
    gmail_account = conf.get("MY_GMAIL_ACCOUNT")
    if not client_id or not client_secret or not rtoken or not gmail_account:
        return None

    now = int(time.time())
    filename = f"/tmp/.{gmail_account}_oauth2_token"
    if os.access(filename, os.O_RDONLY):
        fd = open(filename, "r")
        line = fd.read()
        arr = line.split()
        if len(arr) == 2:
            t = int(arr[1])
            if t > now:
                return gmail_account, arr[0]

    res = gmail_oauth2_token.refresh_token(client_id, client_secret, rtoken)
    if not res:
        return None

    fd = open(filename, "w")
    fd.write(f"{res[0]} {now+res[1]}")
    return gmail_account, res[0]
