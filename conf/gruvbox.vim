" Setting for gruvbox

let g:gruvbox_italic = '1'
let g:gruvbox_vert_split = 'bg0'

colorscheme gruvbox

if g:colors_name ==# 'gruvbox'
    highlight Normal ctermbg=NONE
    highlight Comment cterm=italic

    highlight VimSignatureMarkLine ctermbg=96

    " highlight! clear SpellBad
    " highlight! clear SpellCap
    " highlight! clear SpellRare
    " highlight! SpellBad gui=undercurl guisp=red
    " highlight! SpellCap gui=undercurl guisp=blue
    " highlight! SpellRare gui=undercurl guisp=magenta

    highlight ALEWarning ctermbg=208 ctermfg=223
    highlight ALEError ctermbg=167 ctermfg=223
    " highlight ALEWarningSign ctermbg=208 ctermfg=223
    " highlight ALEErrorSign ctermbg=167 ctermfg=223

    highlight SyntasticWarning ctermbg=208 ctermfg=223
    highlight SyntasticError ctermbg=167 ctermfg=223
    " highlight SyntasticWarningSign ctermbg=208 ctermfg=223
    " highlight SyntasticErrorSign ctermbg=167 ctermfg=223
endif
