scriptencoding utf-8

if !has('gui_macvim')
    let g:Lf_ShortcutF = '<C-p>'
    noremap <A-m> :LeaderfMru<CR>
    noremap <A-f> :LeaderfFunction<CR>
    noremap <A-b> :LeaderfBuffer<CR>
    noremap <A-a> :LeaderfTag<CR>
else
    let g:Lf_ShortcutF = '<C-p>p'
    noremap <C-p>m :LeaderfMru<CR>
    noremap <C-p>f :LeaderfFunction<CR>
    noremap <C-p>b :LeaderfBuffer<CR>
    noremap <C-p>a :LeaderfTag<CR>
endif

let g:Lf_CommandMap = {
        \ '<C-K>': ['<Up>'],
        \ '<C-J>': ['<Down>'],
        \ '<Up>': ['<C-K>'],
        \ '<Down>': ['<C-J>']
        \ }

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

let g:Lf_CtagsFuncOpts = {
        \ 'rust': '--rust-kinds=f',
        \ }
