#!/usr/bin/python3
# -*- coding: utf-8 -*-
#
# @author   Solomon Ng <solomon.wzs@gmail.com>
# @date     2018-10-10
# @version  1.0
# @license  MIT


class Argument(object):
    def __init__(self, arg):
        self.arg = arg
        self.name = arg.split("=")[0].strip()

    def __str__(self):
        return self.name

    def __unicode__(self):
        return self.name

    def is_kwarg(self):
        return "=" in self.arg


def get_arguments(arglist):
    args = [Argument(arg) for arg in arglist.split(",") if arg]
    return [arg for arg in args if arg.name != "self"]


def write_doc_return(snip):
    snip += "@return TODO"


def write_doc_arguments(snip, args):
    if len(args) == 0:
        return

    for arg in args:
        snip += f"@param {arg} TODO"


def write_doc_function(snip, t):
    snip >> 1
    snip += '"""'
    snip += f"TODO: Doc for {t[1]}\n"

    args = get_arguments(t[2])
    if len(args) > 0:
        write_doc_arguments(snip, args)

    if t[1] != "__init__":
        write_doc_return(snip)

    snip += '"""'
