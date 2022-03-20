scriptencoding utf-8

let g:Lf_ShortcutF = '<C-P>p'
noremap <C-P>P :Leaderf file --no-ignore .<CR>
noremap <C-P>m :LeaderfMru<CR>
noremap <C-P>f :LeaderfFunction<CR>
noremap <C-P>b :LeaderfBuffer<CR>
noremap <C-P>a :LeaderfTag<CR>

noremap <silent> <C-P>gs :<C-U><C-R>=printf("Leaderf rg -F -e %s", expand('<cword>'))<CR><CR>
vnoremap <silent> <C-P>gs :<C-U><C-R>=printf("Leaderf rg -F -e %s", leaderf#Rg#visual())<CR><CR>

let g:Lf_CommandMap = {
    \ '<C-K>': ['<Up>'],
    \ '<C-J>': ['<Down>'],
    \ '<Up>': ['<C-K>'],
    \ '<Down>': ['<C-J>']
    \ }

" let g:Lf_StlSeparator = {'left': '', 'right': '', 'font': ''}
let g:Lf_StlSeparator = { 'left': '', 'right': '' }

let g:Lf_RootMarkers = ['.project', '.root', '.svn', '.git']
let g:Lf_WorkingDirectoryMode = 'c'
let g:Lf_WindowHeight = 0.20
let g:Lf_CacheDirectory = expand('~/.vim/cache')
let g:Lf_ShowRelativePath = 0
let g:Lf_HideHelp = 1
" let g:Lf_StlColorscheme = 'powerline'
let g:Lf_PreviewResult = {'Function': 0, 'BufTag': 0}

" let g:Lf_WindowPosition = 'popup'
let g:Lf_PreviewInPopup = 1 " <C-p> to preview

let g:Lf_CtagsFuncOpts = {
    \ 'rust': '--rust-kinds=f',
    \ }

let g:Lf_WildIgnore = {
    \ 'dir'  : ['node_modules'],
    \ 'file' : []
    \ }

cnoreabbrev <expr> Rg ((getcmdtype() is# ':' && getcmdline() is# 'Rg') ?
    \ ('Leaderf rg') : ('Rg'))
cnoreabbrev <expr> Rga ((getcmdtype() is# ':' && getcmdline() is# 'Rga') ?
    \ ('Leaderf rg --no-ignore') : ('Rga'))
