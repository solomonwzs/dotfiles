function! s:Msg_OnError(channel, msg)
    echohl ErrorMsg
    echo 'ERROR: '.a:msg
    echohl None
endfunc


function! s:Msg_OnCb(channel, msg)
    echo a:msg
endfunc


function lib#translate#google(text)
    let qtext = ''
    if a:text ==# ''
        return
    endif

python3 << EOF
import urllib
import vim

text = vim.eval("a:text")
text = urllib.parse.quote_plus(text)
vim.command(f"let qtext = \"{text}\"")
EOF
    
    let pys = g:vimhome.'/pythonx/translate/google.py'
    call job_start(['/usr/bin/python3', pys, qtext], {
                \ 'callback': function('s:Msg_OnCb'),
                \ 'err_cb': function('s:Msg_OnError'),
                \ })
endfunc
