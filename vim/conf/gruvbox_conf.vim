let s:purple = lib#color#group_color('GruvboxPurple')
let s:yellow = lib#color#group_color('GruvboxYellow')
let s:orange = lib#color#group_color('GruvboxOrange')

let s:fg0 = lib#color#group_color('GruvboxFg0')
let s:fg1 = lib#color#group_color('GruvboxFg1')
let s:fg2 = lib#color#group_color('GruvboxFg2')
let s:bg1 = lib#color#group_color('GruvboxBg1')
let s:bg3 = lib#color#group_color('GruvboxBg3')

highlight Normal ctermbg=NONE guibg=NONE
highlight Comment cterm=italic gui=italic

call lib#color#highlight('VimSignatureMarkLine', {'bg': s:purple})

highlight! link GitSignsAdd GruvboxGreen
highlight! link GitSignsChange GruvboxYellow
highlight! link GitSignsDelete GruvboxRed

call lib#color#highlight('my_Warning', {'fg': s:fg1, 'bg': s:yellow})
call lib#color#highlight('my_Error', {'fg': s:fg1, 'bg': s:orange})

call lib#color#highlight('@variable', {'fg': s:fg0})

highlight! link ALEWarning my_Warning
highlight! link ALEError my_Error

highlight! link SyntasticWarning my_Warning
highlight! link SyntasticError my_Error

set cursorline
highlight clear CursorLine
call lib#color#highlight('CursorLine', {'bg': s:bg1})
call lib#color#highlight('LineNR', {'fg': s:bg3})
call lib#color#highlight('CursorLineNR', {'fg': s:fg2, 'attr': 'bold'})

augroup my_conf_gruvbox
  autocmd!

  autocmd VimEnter,WinEnter,BufWinEnter * setlocal cursorline
  autocmd WinLeave * setlocal nocursorline
augroup END
