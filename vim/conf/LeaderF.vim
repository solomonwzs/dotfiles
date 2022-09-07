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
cnoreabbrev <expr> Lf ((getcmdtype() is# ':' && getcmdline() is# 'Lf') ?
    \ ('Leaderf') : ('Lf'))


""" load extensions
if !exists('g:Lf_Extensions')
  let g:Lf_Extensions = {}
endif

if has('nvim')
  let g:Lf_Extensions.man = {
      \ 'source': 'leaderf#man#source',
      \ 'accept': 'leaderf#man#accept',
      \ 'highlights_def': {
        \ 'Lf_hl_manTitle': '^.\+\ze(',
        \ 'Lf_hl_manNumber': '(.\+)',
        \ },
        \ 'highlights_cmd': [
          \ 'hi link Lf_hl_manTitle Title',
          \ 'hi link Lf_hl_manNumber Number',
          \ ],
          \ }
endif

let g:Lf_Extensions.rrg = {
    \ 'source': 'leaderf#rrg#files_with_matches_source',
    \ 'accept': 'leaderf#rrg#files_with_matches_accept',
    \ 'format_line': 'leaderf#rrg#files_with_matches_format_line',
    \ 'arguments': [
      \ {'name': ['pattern']}
      \ ],
    \ }

let g:Lf_Extensions.highlight = {
    \ 'source': 'leaderf#highlight#source',
    \ 'after_enter': 'leaderf#highlight#after_enter',
    \ 'bang_enter': 'lib#common#coc_lf_bang_enter',
    \ 'accept': 'leaderf#highlight#accept',
    \ 'before_exit': 'leaderf#highlight#before_exit',
    \ 'arguments': [
      \ {'name': ['vname']}
      \ ],
    \ }

let g:Lf_Extensions.debug = {
    \ 'source': 'lib#debug#lf_source',
    \ 'before_enter': 'lib#debug#lf_before_enter',
    \ }
