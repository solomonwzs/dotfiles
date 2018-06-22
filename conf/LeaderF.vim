let g:Lf_ShortcutF = '<C-p>'

noremap <A-m> :LeaderfMru<CR>
noremap <A-f> :LeaderfFunction<CR>
noremap <A-b> :LeaderfBuffer<CR>
if $VIM_GROUP != "twit" && $VIM_GROUP != "plug"
    noremap <A-t> :LeaderfTag<CR>
endif
" let g:Lf_StlSeparator = {'left': '', 'right': '', 'font': ''}
let g:Lf_StlSeparator = { 'left': '', 'right': '' }

let g:Lf_RootMarkers = ['.project', '.root', '.svn', '.git']
let g:Lf_WorkingDirectoryMode = 'Ac'
let g:Lf_WindowHeight = 0.20
let g:Lf_CacheDirectory = expand('~/.vim/cache')
let g:Lf_ShowRelativePath = 0
let g:Lf_HideHelp = 1
" let g:Lf_StlColorscheme = 'powerline'
let g:Lf_PreviewResult = {'Function': 0, 'BufTag': 0}
