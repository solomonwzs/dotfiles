let g:defx_icons_enable_syntax_highlight = 0

let s:default_color = lib#color#gruvbox_color('light0')

let g:defx_icons_term_colors = {
    \ 'brown'       : lib#color#gruvbox_color('faded_orange')[1],
    \ 'aqua'        : lib#color#gruvbox_color('neutral_aqua')[1],
    \ 'blue'        : lib#color#gruvbox_color('neutral_blue')[1],
    \ 'darkBlue'    : lib#color#gruvbox_color('faded_blue')[1],
    \ 'purple'      : lib#color#gruvbox_color('neutral_purple')[1],
    \ 'lightPurple' : lib#color#gruvbox_color('bright_purple')[1],
    \ 'red'         : lib#color#gruvbox_color('neutral_red')[1],
    \ 'beige'       : lib#color#gruvbox_color('faded_yellow')[1],
    \ 'yellow'      : lib#color#gruvbox_color('neutral_yellow')[1],
    \ 'orange'      : lib#color#gruvbox_color('neutral_orange')[1],
    \ 'darkOrange'  : lib#color#gruvbox_color('faded_orange')[1],
    \ 'pink'        : lib#color#gruvbox_color('neutral_pink')[1],
    \ 'salmon'      : lib#color#gruvbox_color('bright_orange')[1],
    \ 'green'       : lib#color#gruvbox_color('neutral_green')[1],
    \ 'lightGreen'  : lib#color#gruvbox_color('bright_green')[1],
    \ 'default'     : s:default_color[1],
    \ }

let g:defx_icons_extensions = {
    \ 'bzl':        {'icon': '', 'color': '231', 'term_color': s:default_color[1]},
    \ 'defx':       {'icon': '', 'color': '231', 'term_color': s:default_color[1]},
    \ 'nerdtree':   {'icon': '', 'color': '231', 'term_color': s:default_color[1]},
    \ 'coctree':    {'icon': '', 'color': '231', 'term_color': s:default_color[1]},
    \ 'help':       {'icon': 'ﬤ', 'color': '231', 'term_color': s:default_color[1]},
    \ 'leaderf':    {'icon': '', 'color': '231', 'term_color': s:default_color[1]},
    \ 'man':        {'icon': 'ﬤ', 'color': '231', 'term_color': s:default_color[1]},
    \ 'snippets':   {'icon': '', 'color': '231', 'term_color': s:default_color[1]},
    \ 'tags':       {'icon': '', 'color': '231', 'term_color': s:default_color[1]},
    \ 'tagbar':     {'icon': '', 'color': '231', 'term_color': s:default_color[1]},
    \ 'text':       {'icon': '', 'color': '231', 'term_color': s:default_color[1]},
    \ 'tigrc':      {'icon': '', 'color': '231', 'term_color': s:default_color[1]},
    \ 'tmux':       {'icon': '', 'color': '231', 'term_color': s:default_color[1]},
    \ }

let g:defx_icons_exact_matches = {
    \ 'zshrc':  {'icon': '', 'color': '231', 'term_color': s:default_color[1]},
    \ 'vimrc':  {'icon': '', 'color': '231', 'term_color': s:default_color[1]},
    \ 'tigrc':  {'icon': '', 'color': '231', 'term_color': s:default_color[1]},
    \ '.tigrc': {'icon': '', 'color': '231', 'term_color': s:default_color[1]},
    \ }
