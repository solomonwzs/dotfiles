function! lib#javascript#tern_project()
    let a:wp = getcwd()
    let a:tmpl_file = g:vimhome.'/other/ycm/tern-project.json'
    silent exec '!cp '.a:tmpl_file.' '.a:wp.'/.tern-project'
    redraw!

    if v:shell_error
        echohl ErrorMsg
        echo 'ERROR: Gen .tern-project file error'
        echohl None
    else
        exec 'YcmCompleter RestartServer'
    endif
endfunc
