" Setting for gruvbox

let g:gruvbox_italic = '1'
let g:gruvbox_vert_split = 'bg0'

colorscheme gruvbox

if g:colors_name ==# 'gruvbox'
    highlight Normal ctermbg=NONE
    highlight Comment cterm=italic

    highlight ALEWarning ctermbg=208 ctermfg=223
    highlight ALEError ctermbg=167 ctermfg=223
endif
