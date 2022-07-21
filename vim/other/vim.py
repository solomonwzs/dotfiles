#!/usr/bin/python3
# -*- coding: utf-8 -*-
#
# @author   Solomon Ng <solomon.wzs@gmail.com>
# @date     2022-07-20
# @version  1.0
# @license  MIT

from typing import Callable, Any


class Range:
    """
    Range objects represent a part of a vim buffer.  You can obtain them in a
    number of ways:
            - via vim.current.range (|python-current|)
            - from a buffer's range() method (|python-buffer|)

    A range object is almost identical in operation to a buffer object.  However,
    all operations are restricted to the lines within the range (this line range
    can, of course, change as a result of slice assignments, line deletions, or
    the range.append() method).
    """

    def __init__(self):
        self.start: int
        """
        Index of first line into the buffer
        """

        self.end: int
        """
        Index of last line into the buffer
        """

    def append(self, s: str | list, nr: int = 0) -> None:
        """
        r.append(str)	Append a line to the range
        r.append(str, nr)  Idem, after line "nr"
        r.append(list)	Append a list of lines to the range
                        Note that the option of supplying a list of strings to
                        the append method differs from the equivalent method
                        for Python's built-in list objects.
        r.append(list, nr)  Idem, after line "nr"
        """
        pass


class Window:
    """
    Window objects represent vim windows.  You can obtain them in a number of ways:
            - via vim.current.window (|python-current|)
            - from indexing vim.windows (|python-windows|)
            - from indexing "windows" attribute of a tab page (|python-tabpage|)
            - from the "window" attribute of a tab page (|python-tabpage|)

    You can manipulate window objects only through their attributes.  They have no
    methods, and no sequence or other interface.
    """

    def __init__(self):
        self.buffer: Buffer
        """
        The buffer displayed in this window (RO)
        """

        self.cursor: tuple[int, int]
        """
        The current cursor position in the window
        This is a tuple, (row,col) (RW)
        """

        self.height: int
        """
        The window height, in rows (RW)
        """

        self.width: int
        """
        The window width, in columns (RW)
        """

        self.vars: dict = {}
        """
        The window |w:| variables. Attribute is
        unassignable, but you can change window
        variables this way (RO)
        """

        self.options: dict = {}
        """
        The window-local options. Attribute is
        unassignable, but you can change window
        options this way. Provides access only to
        window-local options, for buffer-local use
        |python-buffer| and for global ones use
        |python-options|. If option is |global-local|
        and local value is missing getting it will
        return None. (RO)
        """

        self.number: int
        """
        Window number.  The first window has number 1.
        This is zero in case it cannot be determined
        (e.g. when the window object belongs to other
        tab page). (RO)
        """

        self.row: int
        """
        On-screen window position in display cells.
        First position is zero. (RO)
        """

        self.col: int
        """
        On-screen window position in display cells.
        First position is zero. (RO)
        """

        self.tabpage: TabPage
        """
        Window tab page. (RO)
        """

        self.valid: bool
        """
        True or False. Window object becomes invalid
        when corresponding window is closed. (RW)
        """


class TabPage:
    """
    Tab page objects represent vim tab pages. You can obtain them in a number of
    ways:
            - via vim.current.tabpage (|python-current|)
            - from indexing vim.tabpages (|python-tabpages|)

    You can use this object to access tab page windows. They have no methods and
    no sequence or other interfaces.
    """

    def __init__(self):
        self.number: int
        """
        The tab page number like the one returned by
        tabpagenr().
        """

        self.windows: list[Window]
        """
        Like python-windows, but for current tab page.
        """

        self.vars: dict = {}
        """
        The tab page t: variables.
        """

        self.window: Window
        """
        Current tabpage window.
        """

        self.valid: bool
        """
        True or False. Tab page object becomes invalid when
        corresponding tab page is closed.
        """


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

    def __len__(self) -> int:
        return 0

    def __getitem__(self, i: int | slice) -> str | list[str] | None:
        return None

    def __setitem__(self, i: int | slice, val: str | list[str] | None) -> None:
        pass

    def __delitem__(self, i: int | slice) -> None:
        pass

    def append(self, s: str | list, nr: int = 0) -> None:
        """
        b.append(str)	Append a line to the buffer
        b.append(str, nr)  Idem, below line "nr"
        b.append(list)	Append a list of lines to the buffer
                        Note that the option of supplying a list of strings to
                        the append method differs from the equivalent method
                        for Python's built-in list objects.
        b.append(list, nr)  Idem, below line "nr"
        """
        pass

    def mark(self, name: str) -> tuple[int, int]:
        """
        Return a tuple (row,col) representing the position
        of the named mark (can also get the []"<> marks)
        """
        return (0, 0)

    def range(self, s: int, e: int) -> Range:
        """
        Return a range object (see |python-range|) which
        represents the part of the given buffer between line
        numbers s and e |inclusive|.
        """
        return Range()


def command(cmd: str) -> None:
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


def find_module(*args, **kwargs) -> object:
    """
    Methods or objects used to implement path loading as described above.
    You should not be using any of these directly except for vim.path_hook
    in case you need to do something with sys.meta_path. It is not
    guaranteed that any of the objects will exist in the future vim
    versions.
    """
    pass


def path_hook(path: str) -> object:
    """
    Methods or objects used to implement path loading as described above.
    You should not be using any of these directly except for vim.path_hook
    in case you need to do something with sys.meta_path. It is not
    guaranteed that any of the objects will exist in the future vim
    versions.
    """
    pass


class Current:
    def __init__(self):
        self.line: str
        """
        The current line (RW)
        """

        self.buffer: Buffer
        """
        The current buffer (RW)
        """

        self.window: Window
        """
        The current window (RW)
        """

        self.tabpage: TabPage
        """
        The current tab page (RW)
        """

        self.range: Range
        """
        The current line range (R0)
        """


error = Exception()
"""
Upon encountering a Vim error, Python raises an exception of type
vim.error.
"""

buffers: list[Buffer] = []
"""
A mapping object providing access to the list of vim buffers.  The
object supports the following operations: >
    :py b = vim.buffers[i]	# Indexing (read-only)
    :py b in vim.buffers	# Membership test
    :py n = len(vim.buffers)	# Number of elements
    :py for b in vim.buffers:	# Iterating over buffer list
"""

windows: list[Window] = []
"""
A sequence object providing access to the list of vim windows.  The
object supports the following operations: >
    :py w = vim.windows[i]	# Indexing (read-only)
    :py w in vim.windows	# Membership test
    :py n = len(vim.windows)	# Number of elements
    :py for w in vim.windows:	# Sequential access
Note: vim.windows object always accesses current tab page.
|python-tabpage|.windows objects are bound to parent |python-tabpage|
object and always use windows from that tab page (or throw vim.error
in case tab page was deleted). You can keep a reference to both
without keeping a reference to vim module object or |python-tabpage|,
they will not lose their properties in this case.
"""

current: Current
"""
An object providing access (via specific attributes) to various
"current" objects available in vim:
    vim.current.line	The current line (RW)		String
    vim.current.buffer	The current buffer (RW)		Buffer
    vim.current.window	The current window (RW)		Window
    vim.current.tabpage	The current tab page (RW)	TabPage
    vim.current.range	The current line range (RO)	Range

The last case deserves a little explanation.  When the :python or
:pyfile command specifies a range, this range of lines becomes the
"current range".  A range is a bit like a buffer, but with all access
restricted to a subset of lines.  See |python-range| for more details.

Note: When assigning to vim.current.{buffer,window,tabpage} it expects
valid |python-buffer|, |python-window| or |python-tabpage| objects
respectively. Assigning triggers normal (with |autocommand|s)
switching to given buffer, window or tab page. It is the only way to
switch UI objects in python: you can't assign to
|python-tabpage|.window attribute. To switch without triggering
autocommands use >
    py << EOF
    saved_eventignore = vim.options['eventignore']
    vim.options['eventignore'] = 'all'
    try:
        vim.current.buffer = vim.buffers[2] # Switch to buffer 2
    finally:
        vim.options['eventignore'] = saved_eventignore
    EOF
"""

tabpages: list[TabPage] = []
"""
A sequence object providing access to the list of vim tab pages. The
object supports the following operations: >
    :py t = vim.tabpages[i]	# Indexing (read-only)
    :py t in vim.tabpages	# Membership test
    :py n = len(vim.tabpages)	# Number of elements
    :py for t in vim.tabpages:	# Sequential access
"""

vars: dict = {}
"""
Dictionary-like objects holding dictionaries with global (|g:|) and
vim (|v:|) variables respectively.
"""

vvars: dict = {}
"""
Dictionary-like objects holding dictionaries with global (|g:|) and
vim (|v:|) variables respectively.
"""

VIM_SPECIAL_PATH: str = ""
"""
String constant used in conjunction with vim path hook. If path hook
installed by vim is requested to handle anything but path equal to
vim.VIM_SPECIAL_PATH constant it raises ImportError. In the only other
case it uses special loader.
"""

if __name__ == "__main__":
    b = Buffer()
    print(b.name)  # write the buffer file name
    b[0] = "hello!!!"  # replace the top line
    b[:] = None  # delete the whole buffer
    del b[:]  # delete the whole buffer
    b[0:0] = ["a line"]  # add a line at the top
    del b[2]  # delete a line (the third)
    b.append("bottom")  # add a line at the bottom
    n = len(b)  # number of lines
    (row, col) = b.mark("a")  # named mark
    r = b.range(1, 5)  # a sub-range of the buffer
    b.vars["foo"] = "bar"  # assign b:foo variable
    b.options["ff"] = "dos"  # set fileformat
    del b.options["ar"]  # same as :set autoread<
