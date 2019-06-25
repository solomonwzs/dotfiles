if executable('ag')
  let g:ackprg = 'ag --vimgrep'
endif
command! -nargs=0 -bang Todo :Ack! Todo
