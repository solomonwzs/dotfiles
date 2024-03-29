" @author     Solomon Ng <solomon.wzs@gmail.com>
" @version    1.0
" @date       2021-01-04
" @license    GPL-2.0+

function! lib#javascript#tern_project()
  let wp = getcwd()
  let tmpl_file = g:vimhome.'/other/ycm/tern-project.json'
  silent exec '!cp '.tmpl_file.' '.wp.'/.tern-project'
  redraw!

  if v:shell_error
    echohl ErrorMsg
    echo 'ERROR: Gen .tern-project file error'
    echohl None
  else
    exec 'YcmCompleter RestartServer'
  endif
endfunc
