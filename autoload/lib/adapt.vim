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


function! lib#adapt#foo()
    call job_start(['/bin/sh', '-c', 'date'], {
                \ 'callback': function('s:fooa', [1, 2, 3, 4, 5]),
                \ 'err_cb': function('s:foob'),
                \ })
endfunc
