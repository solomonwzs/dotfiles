if !exists('g:lib_cscope_code_ext')
    let s:code_ext = ['c', 'cc', 'cpp', 'h', 'hpp']
else
    let s:code_ext = g:lib_cscope_code_ext
end

if !exists('g:lib_cscope_out_dir')
    let s:out_dir = fnameescape($HOME).'/.cache/tags-cscope'
else
    let s:out_dir = g:lib_cscope_out_dir
end

if !exists('g:lib_cscope_build_opts')
    let s:build_opts = ['-b', '-q', ]
else
    let s:build_opts = g:lib_cscope_build_opts
end


function! s:Mkdir_Workspace()
    if !isdirectory(s:out_dir)
        if exists('*mkdir')
            call mkdir(s:out_dir)
        else
            silent exec '!mkdir -p '.s:out_dir
        end
    endif
endfunc


function! s:Basename()
    let a:cwd = getcwd()
    return join(split(a:cwd, '/'), '-')
endfunc


function! s:Gen_Tags_OnCallback(channel, cscope_out)
    if !exists('g:lib_cscope_added')
        silent exec ':cs add '.a:cscope_out
        let g:lib_cscope_added = 1
    end
    silent cs reset
    echo 'reset cscope, file: '.a:cscope_out
endfunc


function! s:Gen_Tags_OnError(channel, msg)
    echohl ErrorMsg
    echo 'ERROR: '.a:msg
    echohl None
endfunc


function! lib#cscope#gen_tags()
    call s:Mkdir_Workspace()

    let a:basename = s:Basename()
    let a:file_list = s:out_dir.'/'.a:basename.'.files'
    let a:names = []
    for a:ext in s:code_ext
        call add(a:names, '-iname "*.'.a:ext.'"')
    endfor
    let a:cmd_1 = 'find . '.join(a:names, ' -o ').' > '.a:file_list

    let a:cscope_out = s:out_dir.'/'.a:basename.'.out'
    let a:cmd_2 = 'cscope '.join(s:build_opts, ' ').
                \' -i '.a:file_list.
                \' -f '.a:cscope_out

    let a:cmd = a:cmd_1.' && '.a:cmd_2.' && echo '.a:cscope_out
    if has('channel') && has('job')
        call job_start(['/bin/sh', '-c', a:cmd], {
                    \ 'callback': function('s:Gen_Tags_OnCallback'),
                    \ 'err_cb': function('s:Gen_Tags_OnError'),
                    \ })
    else
        silent exec '!'.a:cmd
        redraw!
        if v:shell_error
            call s:Gen_Tags_OnError(0, 'set cscope db/conn failure')
        else
            call s:Gen_Tags_OnCallback(0, a:cscope_out)
        endif
    end
endfunc
