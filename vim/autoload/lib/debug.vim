" @author     Solomon Ng <solomon.wzs@gmail.com>
" @version    1.0
" @date       2022-07-24
" @license    MIT

function! lib#debug#foo() abort
  let current = bufnr("%")
  setlocal nospell nofoldenable nowrap noswapfile
  setlocal buftype=nofile bufhidden=hide
  setfiletype log
  execute bn.'bufdo file '.fnameescape("=log=")
  echo bn
endfunction

function! lib#debug#bar() abort
  redir => tmp
  silent verbose highlight
  redir END
  echo tmp
endfunction
