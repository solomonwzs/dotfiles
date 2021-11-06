augroup my_conf_vim_commentary
    autocmd!

    autocmd FileType nginx setlocal commentstring=#\ %s
    autocmd FileType logstash setlocal commentstring=#\ %s
    autocmd FileType c,cpp,typescript,javascript,proto
        \ setlocal commentstring=//\ %s
augroup END
