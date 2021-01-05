" @author     Solomon Ng <solomon.wzs@gmail.com>
" @version    1.0
" @date       2021-01-04
" @license    MIT

let s:default_cb = {'ok_cb': '_msg', 'err_cb': '_msg'}

function! lib#golang#update_pkg()
  let dir = shellescape(expand('%:p:h'))
  let out = system('go list '.dir)
  if v:shell_error
    return
  endif

  let pkg = split(out)[0]
  let cmd = 'go install '.pkg.' && echo ok'
  call lib#async#async_call(['/bin/sh', '-c', cmd], {'err_cb': '_msg'})
endfunc

function! lib#golang#comp_pkg(pkg)
  " let line = getline('.')
  let a:pkg = shellescape(a:pkg)
  let cmd = 'go install '.a:pkg.' && echo '.a:pkg

  call lib#async#async_call(['/bin/sh', '-c', cmd], s:default_cb)
endfunc

function! lib#golang#comp_deps_pkgs(file)
  let cmd = 'go list -f '
      \.shellescape('{{ join .Deps "\n" }}').' '
      \.a:file
      \.'| xargs -i{} go install {} '
      \.'&& echo compiled depend packages'
  call lib#async#async_call(['/bin/sh', '-c', cmd], s:default_cb)
endfunc

function! lib#golang#comp_imps_pkgs(file)
  let cmd = 'go list -f '
      \.shellescape('{{ join .Imports "\n" }}').' '
      \.a:file
      \.'| xargs -i{} go install {} '
      \.'&& echo compiled import packages'
  call lib#async#async_call(['/bin/sh', '-c', cmd], s:default_cb)
endfunc
