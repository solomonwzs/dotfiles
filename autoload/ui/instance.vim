" @author     Solomon Ng <solomon.wzs@gmail.com>
" @version    1.0
" @date       2019-04-04
" @license    MIT

call ui#init#init()


function! s:f_foo() dict
    let self.m_data = self.m_data + 1
endfunc


function! s:f_bar() dict
    echo self.m_data
endfunc


function! s:f_open() dict
endfunc


function! s:f_init_stl_var() dict
    let cx = self.m_category

    let g:ui_stl_category[cx] = '-'
    let g:ui_stl_mode[cx] = '-'
    let g:ui_stl_cwd[cx] = '-'
    let g:ui_stl_running[cx] = ':'
    let g:ui_stl_total[cx] = '0'
    let g:ui_stl_line_number[cx] = '1'
    let g:ui_stl_results_count[cx] = '0'

    let stl =  '%#ui_hl_stl_name_'.cx.'# UI '
    let stl .= '%#ui_hl_stl_separator0_'.cx.'#%{g:ui_stl_separator.left}'
    let stl .= '%#ui_hl_stl_category_'.cx.'# %{g:ui_stl_category.'.cx.'} '
    let stl .= '%#ui_hl_stl_separator1_'.cx.'#%{g:ui_stl_separator.left}'
    let stl .= '%#ui_hl_stl_mode_'.cx.'# %(%{g:ui_stl_mode.'.cx.'}%) '
    let stl .= '%#ui_hl_stl_separator2_'.cx.'#%{g:ui_stl_separator.left}'
    let stl .= '%#ui_hl_stl_cwd_'.cx.'# %<%{g:ui_stl_cwd.'.cx.'} '
    let stl .= '%#ui_hl_stl_separator3_'.cx.'#%{g:ui_stl_separator.left}'
    let stl .= '%=%#ui_hl_stl_blank_'.cx.'#'
    let stl .= '%#ui_hl_stl_separator4_'.cx.'#%{g:ui_stl_separator.right}'
    let stl .= '%#ui_hl_stl_separator5_'.cx.'#%{g:ui_stl_separator.right}'
    let stl .= '%#ui_hl_stl_total_'.cx.'# total%{g:ui_stl_running.'.cx.'} %{g:ui_stl_total.'.cx.'} '

    let self.m_stl = stl
endfunc


function! s:f_set_attrs() dict
    setlocal nobuflisted
    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal undolevels=-1
    setlocal noswapfile
    setlocal nolist
    setlocal norelativenumber
    setlocal nospell
    setlocal wrap
    setlocal nofoldenable
    setlocal foldmethod=manual
    setlocal shiftwidth=4
    setlocal cursorline
    setlocal number
    setlocal filetype=ui
    setlocal nowinfixheight
endfunc


function! ui#instance#new()
    let instance = {
            \ 'm_data': 1,
            \ 'm_category': 'category',
            \ 'f_open': function('s:f_open'),
            \ 'f_set_attrs': function('s:f_set_attrs'),
            \ 'f_foo': function('s:f_foo'),
            \ 'f_bar': function('s:f_bar'),
            \ }
    return instance
endfunc


function! ui#instance#test()
    let i = ui#instance#new()
    call i.f_foo()
    call i.f_bar()

    let j = ui#instance#new()
    call j.f_foo()
    call j.f_bar()

    let s = 'hello'
    let s .= 'world'
    echo s

    " let d0 = {}
    " let d = d0
    " let d.xxx = 123
    " echo d0.xxx
    " echo d0['xxx']
endfunc
