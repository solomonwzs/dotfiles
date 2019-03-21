function! lib#adapt#job_start(cmd, ...)
    let opts = {}
    if a:0 > 0
        let opts = a:1
    endif
    if has('nvim')
        let nopts = {}
        for [k, v] in items(opts)
            if k ==# 'callback'
            elseif k ==# 'err_cb'
            else
                let nopts[k] = v
            endif
        endfor
    else
        " call job_start(a:cmd, opts)
    endif
endfunc

let s:msg = ''

function! s:fooa(ch, data, ...)
    let s = '['.a:0.']'
    let index = 1
    while index <= a:0
        let s = s.'['.a:{index}.']'
        let index = index + 1
    endwhile
    echo s
endfunc


function! s:foob(ch, data)
    echo 'b: '.a:data
endfunc


function! s:bara(id, data, event)
    let s:msg = s:msg.'<<'.a:id.'::'.a:event.'::'
    let s:msg = s:msg.join(a:data, ',').'>>'
    echo s:msg
endfunc


function! s:barb(id, data, event)
    let s:msg = s:msg.'<<'.a:id.'::'.a:event.'::'
    let s:msg = s:msg.a:data.'>>'
    echo s:msg
endfunc


function! s:barc(id, data, event)
    let s:msg = s:msg.'<<'.a:id.'::'.a:event.'::'
    let s:msg = s:msg.join(a:data, ',').'>>'
    echo s:msg
endfunc


function! lib#adapt#foo()
    let cmd = ['/bin/sh', '-c', 'date']
    if has('nvim')
        call jobstart(cmd, {
                    \ 'on_stdout': function('s:bara'),
                    \ 'on_exit': function('s:barb'),
                    \ 'on_stderr': function('s:barc'),
                    \ })
    else
        call job_start(cmd, {
                    \ 'callback': function('s:fooa', [1, 2, 3, 4, 5]),
                    \ 'err_cb': function('s:foob'),
                    \ })
    endif
endfunc
