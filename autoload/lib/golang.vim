function! s:Msg_OnError(channel, msg)
    echohl ErrorMsg
    echo 'ERROR: '.a:msg
    echohl None
endfunc


function! s:Msg_OnCb(channel, msg)
    echo 'OK: '.a:msg
endfunc


function! lib#golang#update_pkg()
    let a:dir = shellescape(expand('%:p:h'))
    let a:out = system('go list '.a:dir)
    if v:shell_error
        return
    endif

    let a:pkg = split(a:out)[0]
    let a:cmd = 'go install '.a:pkg.' && echo ok'
    call job_start(['/bin/sh', '-c', a:cmd], {
                \ 'err_cb': function('s:Msg_OnError'),
                \ })
endfunc


function! lib#golang#comp_pkg(pkg)
    " let a:line = getline('.')
    let a:pkg = shellescape(a:pkg)
    let a:cmd = 'go install '.a:pkg.' && echo '.a:pkg

    call job_start(['/bin/sh', '-c', a:cmd], {
                \ 'callback': function('s:Msg_OnCb'),
                \ 'err_cb': function('s:Msg_OnError'),
                \ })
endfunc


function! lib#golang#comp_deps_pkgs(file)
    let a:cmd = 'go list -f '
                \.shellescape('{{ join .Deps "\n" }}').' '
                \.a:file
                \.'| xargs -i{} go install {} '
                \.'&& echo compiled depend packages'
    call job_start(['/bin/sh', '-c', a:cmd], {
                \ 'callback': function('s:Msg_OnCb'),
                \ 'err_cb': function('s:Msg_OnError'),
                \ })
endfunc


function! lib#golang#comp_imps_pkgs(file)
    let a:cmd = 'go list -f '
                \.shellescape('{{ join .Imports "\n" }}').' '
                \.a:file
                \.'| xargs -i{} go install {} '
                \.'&& echo compiled import packages'
    call job_start(['/bin/sh', '-c', a:cmd], {
                \ 'callback': function('s:Msg_OnCb'),
                \ 'err_cb': function('s:Msg_OnError'),
                \ })
endfunc
