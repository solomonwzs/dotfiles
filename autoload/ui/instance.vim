" @author     Solomon Ng <solomon.wzs@gmail.com>
" @version    1.0
" @date       2019-04-04
" @license    MIT


function! s:set_status_line(stl)
endfunc


function! s:f_foo() dict
    let self.m_data = self.m_data + 1
endfunc


function! s:f_bar() dict
    echo self.m_data
endfunc


function! s:f_open() dict
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
endfunc


function! ui#instance#new()
    let instance = {
            \ 'm_data': 1,
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
endfunc
