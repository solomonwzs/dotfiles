let g:config_Beautifier = {
    \ 'js': {
    \   'indent_size': 2,
    \ },
    \ }

command! -nargs=0 JsBeautify
    \ call JsBeautify()
