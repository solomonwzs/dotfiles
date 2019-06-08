augroup my_conf_vim_commentary
    autocmd FileType nginx setlocal commentstring=#\ %s
    autocmd FileType logstash setlocal commentstring=#\ %s
    autocmd FileType c,cpp setlocal commentstring=//\ %s
augroup END
