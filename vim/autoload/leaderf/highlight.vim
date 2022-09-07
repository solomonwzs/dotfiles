" @author     Solomon Ng <solomon.wzs@gmail.com>
" @version    1.0
" @date       2022-07-24
" @license    MIT

function! leaderf#highlight#source(args) abort
  " redir => tmp
  " silent verbose highlight
  " redir END
  " let res = lib#py#call('helper', 'parse_highlight_info', tmp)
  " return res.data
  return get(g:, a:args.vname)
endfunction

function! leaderf#highlight#after_enter(orig_buf_nr, pos, args) abort
  for line in get(g:, a:args.vname)
    let arr = split(line)
    call matchadd(arr[0], '\v\ze'.arr[0].'\s+\zsxxx')
  endfor
  call matchadd('Comment', '\v\<.*\>')
  execute 'unlet g:'.a:args.vname
endfunction

function! leaderf#highlight#accept(line, args) abort
  let arr = split(a:line)
  let fp = arr[-1][1:-2]
  let arr = split(fp, ':')
  let fn = fp[:-strlen(arr[-1])-2]
  let line = arr[-1]
  if strlen(fn) > 0
    exec 'edit +'.line.' '.escape(fn, ' ')
  endif
endfunction

function! leaderf#highlight#before_exit(orig_buf_nr, pos, args) abort
  call clearmatches()
endfunction
