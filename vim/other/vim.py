#!/usr/bin/python3
# -*- coding: utf-8 -*-
#
# @author   Solomon Ng <solomon.wzs@gmail.com>
# @date     2022-07-20
# @version  1.0
# @license  MIT

from typing import Callable, Any


class Buffer:
    """
    Buffer objects represent vim buffers.  You can obtain them in a number of ways:
            - via vim.current.buffer (|python-current|)
            - from indexing vim.buffers (|python-buffers|)
            - from the "buffer" attribute of a window (|python-window|)

    Buffer objects have two read-only attributes - name - the full file name for
    the buffer, and number - the buffer number.  They also have three methods
    (append, mark, and range; see below).

    You can also treat buffer objects as sequence objects.  In this context, they
    act as if they were lists (yes, they are mutable) of strings, with each
    element being a line of the buffer.  All of the usual sequence operations,
    including indexing, index assignment, slicing and slice assignment, work as
    you would expect.  Note that the result of indexing (slicing) a buffer is a
    string (list of strings).  This has one unusual consequence - b[:] is different
    from b.  In particular, "b[:] = None" deletes the whole of the buffer, whereas
    "b = None" merely updates the variable b, with no effect on the buffer.

    Buffer indexes start at zero, as is normal in Python.  This differs from vim
    line numbers, which start from 1.  This is particularly relevant when dealing
    with marks (see below) which use vim line numbers.
    """

    def __init__(self):
        self.vars: dict
        """
        Dictionary-like object used to access buffer-variables.
        """

        self.options: dict
        """
        Mapping object (supports item getting, setting and
        deleting) that provides access to buffer-local options
        and buffer-local values of |global-local| options. Use
        |python-window|.options if option is window-local,
        this object will raise KeyError. If option is
        |global-local| and local value is missing getting it
        will return None.
        """

        self.name: str
        """
        String, RW. Contains buffer name (full path).
        Note: when assigning to b.name |BufFilePre| and
        |BufFilePost| autocommands are launched.
        """

        self.number: int
        """
        Buffer number. Can be used as |python-buffers| key.
        Read-only.
        """

        self.valid: bool
        """
        True or False. Buffer object becomes invalid when
        corresponding buffer is wiped out.
        """


def command(command: str) -> None:
    """
    Executes the vim (ex-mode) command str.  Returns None.
    """
    pass


def eval(expression: str) -> str | int | dict:
    """
    Evaluates the expression str using the vim internal expression
    evaluator (see |expression|).  Returns the expression result as:
    - a string if the Vim expression evaluates to a string or number
    - a list if the Vim expression evaluates to a Vim list
    - a dictionary if the Vim expression evaluates to a Vim dictionary
    Dictionaries and lists are recursively expanded.
    """
    return ""


def strwidth(s: str) -> int:
    """
    Like |strwidth()|: returns number of display cells str occupies, tab
    is counted as one cell.
    """
    return 0


def foreach_rtp(f: Callable) -> Any:
    """
    Call the given callable for each path in 'runtimepath' until either
    callable returns something but None, the exception is raised or there
    are no longer paths. If stopped in case callable returned non-None,
    vim.foreach_rtp function returns the value returned by callable.
    """
    return ""


def chdir(*args, **kwargs) -> None:
    """
    Run os.chdir or os.fchdir, then all appropriate vim stuff.
    Note: you should not use these functions directly, use os.chdir and
          os.fchdir instead. Behavior of vim.fchdir is undefined in case
          os.fchdir does not exist.
    """
    pass


error = Exception()
"""
Upon encountering a Vim error, Python raises an exception of type
vim.error.
"""

buffers: list[Buffer] = []
"""
A mapping object providing access to the list of vim buffers.
"""
