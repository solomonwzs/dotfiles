function! s:ErrorMsg(msg)
    echohl ErrorMsg
    echo 'ERROR: '.a:msg
    echohl None
endfunc


function! s:Output_Msg_OnError(channel, msg)
    call s:ErrorMsg(a:msg)
endfunc


function! s:Job_Node(cmd, next)
    let node = {'cmd': a:cmd, 'next': a:next}
    function node.jrun(channel, msg)
        call job_start(self.cmd, {
                    \ 'callback': self.next.jrun,
                    \ 'err_cb': function('s:Output_Msg_OnError'),
                    \ })
    endfunc
    return node
endfunc


function! lib#job#exec(commands, finish)
    if has('channel') && has('job')
        let i = len(a:commands) - 1
        let next = {'jrun': a:finish}
        while i >= 0
            let node = s:Job_Node(a:commands[i], next)
            let next = node
            let i -= 1
        endwhile
        call node.jrun(v:null, v:null)
    else
        call s:ErrorMsg('not support, required +channel and +job')
    endif
endfunc
