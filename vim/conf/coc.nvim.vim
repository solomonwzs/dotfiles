" Extensions: 
" - coc-git
" - coc-json
" - coc-python
" - coc-rls
" - coc-snippets
" - coc-tsserver
" - coc-vetur
" - coc-vimlsp

set updatetime=500

let g:markdown_fenced_languages = [
        \ 'vim',
        \ 'help'
        \ ]

nnoremap <silent> <space>g : <C-u>CocList --normal gstatus<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

if !lib#bundle#has_loaded('ultisnips')
    imap <C-a> <Plug>(coc-snippets-expand)
endif

inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

nnoremap <silent> K :call <SID>show_documentation()<CR>

" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

let g:gitgutter_enabled = 1
function! GitGutterGetHunkSummary()
    let blame = get(b:, 'coc_git_status', '')
    return winwidth(0) > 120 ? blame : ''
endfunction
