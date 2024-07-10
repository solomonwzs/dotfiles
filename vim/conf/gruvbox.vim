" Setting for gruvbox

let g:gruvbox_italic = '1'
let g:gruvbox_vert_split = 'bg0'

colorscheme gruvbox

if g:colors_name ==# 'gruvbox'
    highlight Normal ctermbg=NONE guibg=NONE
    highlight Comment cterm=italic guibg=italic

    highlight VimSignatureMarkLine ctermbg=96 guibg=#875f87

    " highlight! clear SpellBad
    " highlight! clear SpellCap
    " highlight! clear SpellRare
    " highlight! SpellBad gui=undercurl guisp=red
    " highlight! SpellCap gui=undercurl guisp=blue
    " highlight! SpellRare gui=undercurl guisp=magenta

    highlight ALEWarning ctermbg=208 ctermfg=223 guibg=#ff8700 guifg=#ffd7af
    highlight ALEError ctermbg=167 ctermfg=223 guibg=#d75f5f guifg=#ffd7af
    " highlight ALEWarningSign ctermbg=208 ctermfg=223
    " highlight ALEErrorSign ctermbg=167 ctermfg=223

    highlight SyntasticWarning ctermbg=208 ctermfg=223 guibg=#ff8700 guifg=#ffd7af
    highlight SyntasticError ctermbg=167 ctermfg=223 guibg=#d75f5f guifg=#ffd7af
    " highlight SyntasticWarningSign ctermbg=208 ctermfg=223
    " highlight SyntasticErrorSign ctermbg=167 ctermfg=223
endif

set cursorline
highlight clear CursorLine
highlight CursorLine ctermbg=237 guibg=#3a3a3a
highlight LineNR ctermfg=240 guifg=#585858
highlight CursorLineNR cterm=bold ctermfg=255 gui=bold guifg=#eeeeee
augroup my_conf_gruvbox
    autocmd!

    autocmd VimEnter,WinEnter,BufWinEnter * setlocal cursorline
    autocmd WinLeave * setlocal nocursorline
augroup END
