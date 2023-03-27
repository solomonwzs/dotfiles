" @author     Solomon Ng <solomon.wzs@gmail.com>
" @version    1.0
" @date       2018-10-10
" @license    GPL-2.0+

function! s:setStatusLine(stl)
  let bufnr = bufnr('%')
  for n in range(1, winnr('$'))
    if winbufnr(n) == bufnr
      call setwinvar(n, '&statusline', a:stl)
    endif
  endfor
endfunc

function! ui#window#new(argv)
  let position = get(a:argv, 'position', 'bottom')
  let size = get(a:argv, 'size', 0.3)
  let bufname = get(a:argv, 'bufname', 'undefined')
  let winname = get(a:argv, 'winname', 'undefined')

  if size >= 1
    let lines = size
  elseif size > 0
    let lines = &lines * size
  else
    return
  endif

  silent! exec printf('noa keepa keepj %s sp %s', position, bufname)
  silent! exec printf('resize %s', lines)
  silent! exec printf('setlocal filetype=%s', winname)

  setlocal bufhidden=hide
  setlocal buftype=nofile
  setlocal cursorline
  setlocal foldcolumn=0
  setlocal foldmethod=manual
  setlocal nobuflisted
  setlocal nofoldenable
  setlocal nolist
  setlocal norelativenumber
  setlocal nospell
  setlocal noswapfile
  setlocal number
  setlocal shiftwidth=4
  setlocal undolevels=-1
  setlocal wrap
  " setlocal nomodifiable

  redrawstatus

  " let stl = printf('%!airline#statusline(%s)', winnr())
  " exec printf('augroup Lib_win_%s_Colorscheme', bufname)
  " exec printf('au ColorScheme * call s:setStatusLine(%s)', stl)
  " exec printf('au WinEnter,FileType * call s:setStatusLine(%s)', stl)
  " exec printf('augroup END')
  return win_getid()
endfunc

function! ui#window#test()
  let argv = {'position': 'top'}
  echo ui#window#new(argv)
endfunc
