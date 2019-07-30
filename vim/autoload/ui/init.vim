" @author     Solomon Ng <solomon.wzs@gmail.com>
" @version    1.0
" @date       2019-04-09
" @license    MIT

scriptencoding utf-8

let g:ui_stl_category = {}
let g:ui_stl_mode = {}
let g:ui_stl_cwd = {}
let g:ui_stl_running = {}
let g:ui_stl_total = {}
let g:ui_stl_line_number = {}
let g:ui_stl_results_count = {}

let g:ui_stl_separator = get(g:, 'ui_stl_separator', {})
if !has_key(g:ui_stl_separator, 'left')
    let g:ui_stl_separator['left'] = ''
endif
if !has_key(g:ui_stl_separator, 'right')
    let g:ui_stl_separator['right'] = ''
endif

function! ui#init#init()
endfunc
