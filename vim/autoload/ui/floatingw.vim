" @author     Solomon Ng <solomon.wzs@gmail.com>
" @version    1.0
" @date       2019-07-19
" @license    MIT

function! s:f_floatit(arg) dict
    let size_percent_width = get(a:arg, 'm_size_pw', 0)
    let size_percent_height = get(a:arg, 'm_size_ph', 0)
    let size_w = get(a:arg, 'size_w', 0)
    let size_h = get(a:arg, 'size_h', 0)

    if size_w == 0
        if size_percent_width != 0
            let size_w = self.m
        endif
    endif
endfunction

function! ui#floatingw#new(arg)
    let nr = winnr()
    let instance = {
            \ 'm_winnr': nr,
            \ 'm_winw': winwidth(nr),
            \ 'm_winh': winheight(nr),
            \ 'f_floatit': function('s:f_floatit'),
            \ }
    return instance
endfunction

function! ui#floatingw#test()
    let obj = ui#floatingw#new({})
    call obj.f_floatit(123)
endfunction
