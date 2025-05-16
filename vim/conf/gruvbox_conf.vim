function! s:get_gruvbox_color(group)
  let hid = hlID(a:group)
  let guiColor = synIDattr(hid, 'fg', 'gui')
  let termColor = synIDattr(hid, 'fg', 'cterm')
  return [ guiColor, termColor ]
endfunction

let s:purple = s:get_gruvbox_color('GruvboxPurple')
let s:yellow = s:get_gruvbox_color('GruvboxYellow')
let s:orange = s:get_gruvbox_color('GruvboxOrange')

let s:fg1 = s:get_gruvbox_color('GruvboxFg1')
let s:fg2 = s:get_gruvbox_color('GruvboxFg2')
let s:bg2 = s:get_gruvbox_color('GruvboxBg2')
let s:bg1 = s:get_gruvbox_color('GruvboxBg1')

highlight Normal ctermbg=NONE guibg=NONE
highlight Comment cterm=italic gui=italic

call lib#color#highlight('VimSignatureMarkLine', {'bg': s:purple})

highlight! link GitSignsAdd GruvboxGreen
highlight! link GitSignsChange GruvboxYellow
highlight! link GitSignsDelete GruvboxRed

call lib#color#highlight('my_Warning', {'fg': s:fg1, 'bg': s:yellow})
call lib#color#highlight('my_Error', {'fg': s:fg1, 'bg': s:orange})

highlight! link ALEWarning my_Warning
highlight! link ALEError my_Error

highlight! link SyntasticWarning my_Warning
highlight! link SyntasticError my_Error

set cursorline
highlight clear CursorLine
call lib#color#highlight('CursorLine', {'bg': s:bg1})
call lib#color#highlight('LineNR', {'fg': s:bg2})
call lib#color#highlight('CursorLineNR', {'fg': s:fg2, 'attr': 'bold'})

augroup my_conf_gruvbox
  autocmd!

  autocmd VimEnter,WinEnter,BufWinEnter * setlocal cursorline
  autocmd WinLeave * setlocal nocursorline
augroup END
