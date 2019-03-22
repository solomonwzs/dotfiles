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

function! s:append_msg(msg)
    let s:msg = s:msg.a:msg
endfunc

function! s:fooa(ch, data, ...)
    call s:append_msg('['.a:0.']')
    let index = 1
    while index <= a:0
        call s:append_msg('['.a:{index}.']')
        let index = index + 1
    endwhile
    echo s:msg
endfunc


function! s:foob(ch, data)
    echo 'b: '.a:data
endfunc


function! s:bara(id, data, event)
    call s:append_msg('<<'.a:id.'::'.a:event.'::')
    call s:append_msg(join(a:data, ',').'>>')
    echo s:msg
endfunc


function! s:barb(id, exit_code, event)
    call s:append_msg('<<'.a:id.'::'.a:event.'::')
    call s:append_msg(a:exit_code.'>>')
    echo s:msg
endfunc


function! s:barc(id, data, event)
    call s:append_msg('<<'.a:id.'::'.a:event.'::')
    call s:append_msg(join(a:data, ',').'>>')
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
