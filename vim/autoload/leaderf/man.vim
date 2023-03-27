" @author     Solomon Ng <solomon.wzs@gmail.com>
" @version    1.0
" @date       2022-07-21
" @license    GPL-2.0+

if !has('nvim')
  finish
endif

function! leaderf#man#source(args) abort
  return man#complete(0,0,0)
endfunction

function! leaderf#man#accept(line, args) abort
  execute 'Man ' . a:line
endfunction
