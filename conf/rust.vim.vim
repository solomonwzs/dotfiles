let g:rustfmt_options = '--config-path '.g:vimhome.'/other/rust/rustfmt.toml'

augroup my_conf_rust_vim
    if executable('rustfmt')
        autocmd FileType rust
                \ autocmd! BufWritePost <buffer> call rustfmt#Format()
    endif
augroup END
