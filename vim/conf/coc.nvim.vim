" let g:coc_global_extensions = [
"         \ 'coc-git',
"         \ 'coc-json',
"         \ 'coc-pyright',
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
    elseif &filetype ==? 'man'
        execute 'Man '.expand('<cword>')
    else
        call CocAction('doHover')
    endif
endfunction

function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~# '\s'
endfunction

if !lib#bundle#has_loaded('ultisnips')
    imap <C-a> <Plug>(coc-snippets-expand)
endif

nnoremap <silent> <space>cg :<C-u>CocList --normal gstatus<CR>
nnoremap <silent> <space>ce :<C-u>CocList extensions<CR>
nnoremap <silent> <space>cr :<C-u>CocRestart<CR>
nnoremap <silent> <space>log :<C-u>CocCommand workspace.showOutput coc-ext<CR>

" inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
" inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <silent><expr> <TAB>
        \ pumvisible() ? "\<C-n>" :
        \ <SID>check_back_space() ? "\<TAB>" :
        \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
inoremap <expr><CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

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

nmap <silent> <space>cf <Plug>(coc-format)
vmap <silent> <space>cf <Plug>(coc-format-selected)
" command! -nargs=0 Format call CocAction('format')
" command! -range=% Format <line1>,<line2>call CocAction('formatSelected', 'v')

" for coc-ext-common
nmap <silent> <leader>t <Plug>(coc-ext-translate)
vmap <silent> <leader>t <Plug>(coc-ext-translate-v)

vmap <silent> <leader>du <Plug>(coc-ext-decode-utf8)
vmap <silent> <leader>eu <Plug>(coc-ext-encode-utf8)

vmap <silent> <leader>dg <Plug>(coc-ext-decode-gbk)
vmap <silent> <leader>eg <Plug>(coc-ext-encode-gbk)

vmap <silent> <leader>dm <Plug>(coc-ext-decode-mime)

augroup my_coc_nvim
  autocmd!
  autocmd FileType python let b:coc_root_patterns = ['.env']

  autocmd BufEnter,BufRead *.encrypted set filetype=encrypted
  autocmd FileType encrypted setl nomodifiable buftype=nofile
augroup END
