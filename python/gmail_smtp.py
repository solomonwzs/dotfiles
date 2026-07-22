#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# @author   Solomon Ng <solomon.wzs@gmail.com>
# @date     2026-07-21
# @version  1.0
# @license  GPL-2.0+

import base64
import smtplib
import sys
import logging
import utils

SERV = "smtp.gmail.com"
PORT = 587

logging.basicConfig(
    format="\033[3;32m(%(levelname).1s) %(asctime)s <%(process)d> [%(filename)s:%(funcName)s:%(lineno)s]\033[0m %(message)s",
    level=logging.DEBUG,
    datefmt="%y-%m-%d %H:%M:%S",
)


class redirect_stderr:
    def __init__(self):
        self._color = ""
        self._orig_err = None

    def __enter__(self):
        self._orig_err = getattr(sys, "stderr")
        setattr(sys, "stderr", self)
        return self

    def write(self, msg):
        self._color = ""
        if msg == "send:":
            self._color = "\033[3;35m"
        elif msg[-1] == "\n":
            self._color = "\033[0m"
        if len(msg) < 10240:
            sys.stdout.write("%s%s" % (self._color, msg))
        else:
            sys.stdout.write(
                "%s%.256s ...(%d bytes more)\n\033[0m"
                % (self._color, msg, len(msg) - 256)
            )

    def flush(self):
        pass

    def __exit__(self, *_):
        if self._color != "":
            sys.stdout.write("\033[0m")
        setattr(sys, "stderr", self._orig_err)


def send_email(recipients, eml_file):
    auth = utils.get_gmail_oauth2_token()
    if not auth:
        logging.error("failed to get OAuth2 token")
        return False

    sender = auth[0]
    auth_string = "user=%s\1auth=Bearer %s\1\1" % (auth[0], auth[1])
    auth_b64 = base64.b64encode(auth_string.encode("utf8")).decode("ascii")

    try:
        with open(eml_file, "rb") as fd:
            eml_content = fd.read()
    except IOError as e:
        logging.error("unable to read eml file '%s': %s", eml_file, e)
        return False

    try:
        conn = smtplib.SMTP(SERV, PORT)
        conn.set_debuglevel(1)
        conn.ehlo()
        conn.starttls()
        conn.ehlo()
        conn.docmd("AUTH", "XOAUTH2 " + auth_b64)
        conn.sendmail(sender, recipients, eml_content)
        conn.quit()
        logging.info("email sent to %s", recipients)
        return True
    except smtplib.SMTPException as e:
        logging.error("SMTP error: %s", e)
        return False


def usage():
    print("Usage: %s <recipients> <eml_file>" % sys.argv[0], file=sys.stderr)
    print(
        "  recipients: comma-separated email addresses (no spaces)",
        file=sys.stderr,
    )
    print("  eml_file:   path to the .eml file to send", file=sys.stderr)
    sys.exit(1)


if __name__ == "__main__":
    if len(sys.argv) != 3:
        usage()

    recipients = [r.strip() for r in sys.argv[1].split(",") if r.strip()]
    if not recipients:
        logging.error("no valid recipients")
        usage()

    eml_file = sys.argv[2]
    with redirect_stderr() as _:
        if not send_email(recipients, eml_file):
            sys.exit(1)
