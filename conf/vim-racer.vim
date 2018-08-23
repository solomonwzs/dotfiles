" vim-racer
" Install racer
let g:racer_experimental_completer = 1

augroup racer_group
    autocmd Filetype rust setlocal hidden
    autocmd FileType rust nmap gd <Plug>(rust-def)
    autocmd FileType rust nmap gs <Plug>(rust-def-split)
    autocmd FileType rust nmap gx <Plug>(rust-def-vertical)
    autocmd FileType rust nmap <leader>gd <Plug>(rust-doc)
augroup END
