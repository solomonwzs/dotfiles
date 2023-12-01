#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# @author   Solomon Ng <solomon.wzs@gmail.com>
# @date     2023-12-01
# @version  1.0
# @license  GPL-2.0+

import imaplib
import logging
import utils
import sys

SERV = "imap.gmail.com"
PORT = 993

logging.basicConfig(
    format="\033[3;32m(%(levelname).1s) %(asctime)s <%(process)d> [%(filename)s:%(funcName)s:%(lineno)s]\033[0m %(message)s",
    level=logging.DEBUG,
    datefmt="%y-%m-%d %H:%M:%S",
)


class redirect_stderr:
    def __init__(self):
        self._orig_err = None

    def __enter__(self):
        self._orig_err = getattr(sys, "stderr")
        setattr(sys, "stderr", self)
        return self

    def write(self, msg):
        color = "\033[3;35m" if msg[11] == ">" else ""
        if len(msg) < 10240:
            sys.stdout.write("%s%s\033[0m" % (color, msg))
        else:
            sys.stdout.write(
                "%s%.256s ...(%d bytes more)\n\033[0m"
                % (color, msg, len(msg) - 256)
            )

    def flush(self):
        pass

    def __exit__(self, *_):
        setattr(sys, "stderr", self._orig_err)


def test():
    auth = utils.get_gmail_oauth2_token()
    if not auth:
        return

    auth_string = "user=%s\1auth=Bearer %s\1\1" % (auth[0], auth[1])
    mailbox = '"__NOTE"'
    msgid = "__message"
    with redirect_stderr() as _:
        conn = imaplib.IMAP4_SSL(SERV)
        conn.debug = 4
        conn.authenticate("XOAUTH2", lambda _: auth_string.encode("utf8"))
        conn.list()

        conn.select(mailbox=mailbox)
        res = conn.uid("SEARCH", "Subject", msgid)
        # res = conn.search(None, "ALL")
        if res[0] != "OK":
            return
        uids = res[1][0].decode("utf8").split()
        logging.debug(uids)

        # for uid in uids:
        #     res = conn.fetch(uid, "(RFC822)")
        #     logging.debug(res)
        #     conn.store(uid, "+FLAGS", "\\Deleted")
        # conn.expunge()

        # conn.append(
        #     mailbox=mailbox,
        #     flags="(\\Draft \\Seen)",
        #     date_time="",
        #     message=f"From: <{auth[0]}>\r\nSubject: {msgid}\r\n\r\nhello world".encode(
        #         "utf8"
        #     ),
        # )
        # conn.uid("SEARCH", "Subject", msgid)


if __name__ == "__main__":
    test()
