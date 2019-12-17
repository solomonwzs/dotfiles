" let g:coc_global_extensions = [
"         \ 'coc-git',
"         \ 'coc-json',
"         \ 'coc-python',
"         \ 'coc-rls',
"         \ 'coc-snippets',
"         \ 'coc-tsserver',
"         \ 'coc-vetur',
"         \ 'coc-vimlsp',
"         \ ]

let g:markdown_fenced_languages = [
        \ 'vim',
        \ 'help'
        \ ]

function! s:show_documentation()
    if (index(['vim', 'help'], &filetype) >= 0)
        execute 'h '.expand('<cword>')
    else
        call CocAction('doHover')
    endif
endfunction

if !lib#bundle#has_loaded('ultisnips')
    imap <C-a> <Plug>(coc-snippets-expand)
endif

nnoremap <silent> <space>cg :<C-u>CocList --normal gstatus<CR>
nnoremap <silent> <space>ce :<C-u>CocList extensions<CR>
nnoremap <silent> <space>cr :<C-u>CocRestart<CR>

inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

nnoremap <silent> K :call <SID>show_documentation()<CR>

" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

nmap <silent> <space>ci <Plug>(coc-diagnostic-info)
nmap <silent> <space>cn <Plug>(coc-diagnostic-next)
nmap <silent> <space>cp <Plug>(coc-diagnostic-prev)
nmap <silent> <space>cs :<C-U><C-R>=printf("CocSearch -w %s", expand('<cword>'))<CR><CR>

" let g:gitgutter_enabled = 1
" function! GitGutterGetHunkSummary()
"     let blame = get(b:, 'coc_git_status', '')
"     return winwidth(0) > 120 ? blame : ''
" endfunction
