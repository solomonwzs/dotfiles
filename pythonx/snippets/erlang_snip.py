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
        self.name = arg.split('::')[0].strip()

    def __str__(self):
        return self.name

    def __unicode__(self):
        return self.name

    def is_kwarg(self):
        return '=' in self.arg


def write_arguments(snip, t):
    args = [Argument(arg).name for arg in t[2].split(',') if arg]
    snip.rv = ', '.join(args)
