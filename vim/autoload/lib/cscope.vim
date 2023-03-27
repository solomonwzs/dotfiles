" @author     Solomon Ng <solomon.wzs@gmail.com>
" @version    1.0
" @date       2021-01-04
" @license    GPL-2.0+

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

function! s:mkdir_workspace()
  if !isdirectory(s:out_dir)
    if exists('*mkdir')
      call mkdir(s:out_dir)
    else
      silent exec '!mkdir -p '.s:out_dir
    end
  endif
endfunc

function! s:basename()
  let cwd = getcwd()
  return join(split(cwd, '/'), '-')
endfunc

function! s:gen_tags_oncallback(cscope_out)
  if !exists('g:lib_cscope_added')
    silent exec ':cs add '.a:cscope_out[0]
    let g:lib_cscope_added = 1
  end
  silent cs reset
  echo 'reset cscope, file: '.a:cscope_out[0]
endfunc

function! lib#cscope#gen_tags()
  call s:mkdir_workspace()

  let basename = s:basename()
  let file_list = s:out_dir.'/'.basename.'.files'
  let names = []
  for ext in s:code_ext
    call add(names, '-iname "*.'.ext.'"')
  endfor
  let cmd_1 = 'find . '.join(names, ' -o ').' > '.file_list

  let cscope_out = s:out_dir.'/'.basename.'.out'
  let cmd_2 = 'cscope '.join(s:build_opts, ' ').
          \' -i '.file_list.
          \' -f '.cscope_out

  let cmd = cmd_1.' && '.cmd_2.' && echo '.cscope_out
  call lib#async#async_call(['/bin/sh', '-c', cmd], {
          \ 'ok_cb': function('s:gen_tags_oncallback'),
          \ 'err_cb': '_msg',
          \ })
endfunc
