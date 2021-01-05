if exists('b:current_syntax')
    finish
endif

syntax region UIFloatTitle start=/^\[/ end=/\]/ fold

highlight UIFloat ctermbg=240
highlight UIFloatTitle ctermfg=223 cterm=bold
