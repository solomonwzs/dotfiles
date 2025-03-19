" @author     Solomon Ng <solomon.wzs@gmail.com>
" @version    1.0
" @date       2022-07-24
" @license    GPL-2.0+

function! lib#debug#foo(args) abort
  " let current = bufnr("%")
  " setlocal nospell nofoldenable nowrap noswapfile
  " setlocal buftype=nofile bufhidden=hide
  " setfiletype log
  " execute bn.'bufdo file '.fnameescape("=log=")
  " echo bn
  call lib#py#call('logging', 'info', a:args)
endfunction

function! lib#debug#bar() abort
  redir => tmp
  silent verbose highlight
  redir END
  echo tmp
endfunction

function! lib#debug#lf_source(a)
  call lib#py#call('logging', 'info', [1, a:a])
  return ['1', '2', '3', '4']
endfunction

function! lib#debug#lf_before_enter(a)
  call lib#py#call('logging', 'info', [2, a:a])
endfunction

function! lib#debug#promt()
  echo '[Y]es/[N]o'
  let choice = input('> ')

  redraw

  if choice =~? '^y\(es\)\?$'
    return 1
  elseif choice =~? '^n\(o\)\?$'
    return 0
  else
    echo 'Invalid choice. Please enter Yes or No.'
    return lib#debug#promt()
  endif
endfunction

function! lib#debug#popup()
  let lines = ['# abc', '## 123', '---', 'hello world']
  let buf = nvim_create_buf(v:true, v:true)
  call nvim_buf_set_lines(buf, 0, -1, v:false, lines)
  call setbufvar(buf, '&buftype', 'nofile')

  let win = nvim_open_win(buf, v:false, {
      \ 'width': 20,
      \ 'height': 10,
      \ 'col': 0,
      \ 'row': 1,
      \ 'relative': 'cursor',
      \ })
  call setbufvar(buf, '&filetype', 'markdown')
endfunction
