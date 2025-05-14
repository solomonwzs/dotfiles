let g:gruvbox_italic = '1'
let g:gruvbox_vert_split = 'bg0'

colorscheme gruvbox

highlight StatusLine cterm=NONE gui=NONE
highlight StatusLineNC cterm=NONE gui=NONE

exec 'so '.g:vimhome.'/conf/gruvbox_conf.vim'

if lib#bundle#has_loaded('lightline.vim')
  let g:lightline.colorscheme = 'gruvbox'
endif
