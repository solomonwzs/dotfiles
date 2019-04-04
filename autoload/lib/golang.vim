function! s:Msg_OnError(channel, msg)
    echohl ErrorMsg
    echo 'ERROR: '.a:msg
    echohl None
endfunc


function! s:Msg_OnCb(channel, msg)
    echo 'OK: '.a:msg
endfunc


function! lib#golang#update_pkg()
    let dir = shellescape(expand('%:p:h'))
    let out = system('go list '.dir)
    if v:shell_error
        return
    endif

    let pkg = split(out)[0]
    let cmd = 'go install '.pkg.' && echo ok'
    call job_start(['/bin/sh', '-c', cmd], {
            \ 'err_cb': function('s:Msg_OnError'),
            \ })
endfunc


function! lib#golang#comp_pkg(pkg)
    " let line = getline('.')
    let a:pkg = shellescape(a:pkg)
    let cmd = 'go install '.a:pkg.' && echo '.a:pkg

    call job_start(['/bin/sh', '-c', cmd], {
            \ 'callback': function('s:Msg_OnCb'),
            \ 'err_cb': function('s:Msg_OnError'),
            \ })
endfunc


function! lib#golang#comp_deps_pkgs(file)
    let cmd = 'go list -f '
            \.shellescape('{{ join .Deps "\n" }}').' '
            \.a:file
            \.'| xargs -i{} go install {} '
            \.'&& echo compiled depend packages'
    call job_start(['/bin/sh', '-c', cmd], {
            \ 'callback': function('s:Msg_OnCb'),
            \ 'err_cb': function('s:Msg_OnError'),
            \ })
endfunc


function! lib#golang#comp_imps_pkgs(file)
    let cmd = 'go list -f '
            \.shellescape('{{ join .Imports "\n" }}').' '
            \.a:file
            \.'| xargs -i{} go install {} '
            \.'&& echo compiled import packages'
    call job_start(['/bin/sh', '-c', cmd], {
            \ 'callback': function('s:Msg_OnCb'),
            \ 'err_cb': function('s:Msg_OnError'),
            \ })
endfunc
