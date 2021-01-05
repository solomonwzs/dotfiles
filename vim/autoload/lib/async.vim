" @author     Solomon Ng <solomon.wzs@gmail.com>
" @version    1.0
" @date       2020-12-31
" @license    MIT

function s:default_ok_cb(data, ...)
  echo 'OK: '.join(a:data, ' ')
endfunc

function s:default_err_cb(data, ...)
  echohl ErrorMsg
  echo 'ERR: '.join(a:data, ' ')
  echohl None
endfunc

function s:ok_callback_vim(cb, ch, data)
  let lines = [a:data]
  while ch_info(a:ch)['out_status'] !=# 'closed'
    let line = ch_read(a:ch)
    if (!empty(line))
      call add(lines, line)
    endif
  endwhile
  call a:cb(lines)
endfunc

function s:err_callback_vim(cb, ch, data)
  let lines = [a:data]
  while ch_info(a:ch)['err_status'] !=# 'closed'
    let line = ch_read(a:ch, {'part': 'err'})
    if (!empty(line))
      call add(lines, line)
    endif
  endwhile
  call a:cb(lines)
endfunc

function s:ok_callback_nvim(ldata, id, data, event)
  if a:event ==# 'stdout' && a:data != ['']
    call extend(a:ldata, a:data)
  endif
endfunc

function s:err_callback_nvim(ldata, id, data, event)
  if a:event ==# 'stderr' && a:data != ['']
    call extend(a:ldata, a:data)
  endif
endfunc

function s:exit_callback_nvim(ok_cb, err_cb, ldata, id, exit_code, event)
  if a:exit_code == 0
    if a:ok_cb != 0
      call a:ok_cb(a:ldata)
    endif
  else
    if a:err_cb != 0
      call a:err_cb(a:ldata)
    endif
  endif
endfunc

function s:parse_nvim_args(opts)
  let nvim_opts = {}
  let ldata = []
  let Ok_cb = 0
  let Err_cb = 0
  if has_key(a:opts, 'ok_cb')
    let Ok_cb = a:opts.ok_cb
    if a:opts.ok_cb ==# '_msg'
      let Ok_cb = function('s:default_ok_cb')
    endif
    let nvim_opts.on_stdout = function('s:ok_callback_nvim', [ldata])
  endif
  if has_key(a:opts, 'err_cb')
    let Err_cb = a:opts.err_cb
    if a:opts.err_cb ==# '_msg'
      let Err_cb = function('s:default_err_cb')
    endif
    let nvim_opts.on_stderr = function('s:err_callback_nvim', [ldata])
  endif
  let nvim_opts.on_exit = function('s:exit_callback_nvim', [Ok_cb, Err_cb, ldata])
  return nvim_opts
endfunc

function s:parse_vim_args(opts)
  let vim_opts = {}
  if has_key(a:opts, 'ok_cb')
    let args = [a:opts.ok_cb]
    if a:opts.ok_cb ==# '_msg'
      let args = [function('s:default_ok_cb')]
    endif
    let vim_opts.out_cb = function('s:ok_callback_vim', args)
  endif
  if has_key(a:opts, 'err_cb')
    let args = [a:opts.err_cb]
    if a:opts.err_cb ==# '_msg'
      let args = [function('s:default_err_cb')]
    endif
    let vim_opts.err_cb = function('s:err_callback_vim', args)
  endif
  return vim_opts
endfunc

function! lib#async#async_call(cmd, ...)
  let opts = {}
  if a:0 >= 1
    let opts = a:1
  endif

  if has('nvim')
    call jobstart(a:cmd, s:parse_nvim_args(opts))
  elseif has('channel') && has('job')
    call job_start(a:cmd, s:parse_vim_args(opts))
    " call job_start(a:cmd, {
    "         \ 'callback': function('s:fooa'),
    "         \ })
  else
    silent exec '!'.join(a:cmd, ' ')
    redraw!
    if v:shell_error
      if has_key(opts, 'ok_cb')
        call s:default_ok_cb(a:cmd)
      endif
    else
      if has_key(opts, 'ok_cb')
        call s:default_err_cb(a:cmd)
      endif
    endif
  endif
endfunc

let s:msg = ''
function! s:append_msg(msg)
  let s:msg = s:msg.a:msg
endfunc
function! s:foo(...)
  call s:append_msg('['.a:0.']')
  call s:append_msg('['.ch_info(a:1)['err_status'].']')
  let index = 1
  while index <= a:0
    call s:append_msg('<'.a:{index}.'>')
    let index = index + 1
  endwhile
  echo s:msg
endfunc

function! lib#async#debug()
  let cmd = ['/bin/sh', '-c', 'ls -l']
  call lib#async#async_call(cmd, {'ok_cb': '_msg', 'err_cb': '_msg'})
endfunc
