" @author     Solomon Ng <solomon.wzs@gmail.com>
" @version    1.0
" @date       2018-10-10
" @license    MIT


function! s:dget(dict, key, default)
    if has_key(a:dict, a:key)
        return a:dict[a:key]
    else
        return a:default
    endif
endfunc


function! lib#window#new(argv)
    echo s:dget(a:argv, 'position', 'bottom')
endfunc
