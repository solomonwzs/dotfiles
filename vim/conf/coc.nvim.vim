scriptencoding utf-8

" runtime! auoload/coc/ui.vim

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

let s:is_nvim = has('nvim')

let g:coc_disable_transparent_cursor = 1

let g:coc_borderchars = ['─', '│', '─', '│', '╭', '╮', '╯', '╰']

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

function! s:init_coc() abort
  " runtime! autoload/coc/ui.vim
  call coc#notify#create(['Initialized coc.nvim for LSP support'], {
      \ 'title': 'LSP Status',
      \ 'kind': 'info',
      \ 'borderhighlight': 'CocInfoFloat',
      \ 'timeout': 2500,
      \ })
endfunction

function! s:status_notify() abort
  let l:status = get(g:, 'coc_status', '')
  let l:level = 'info'
  if empty(l:status) | return '' | endif
  call v:lua.require('coc-notify').coc_status_notify(l:status, l:level)
endfunction

function! s:diagnostic_notify() abort
  let l:info = get(b:, 'coc_diagnostic_info', {})
  if empty(l:info) | return '' | endif
  let l:msgs = []
  let l:level = 'info'
  if get(l:info, 'warning', 0)
    let l:level = 'warn'
  endif
  if get(l:info, 'error', 0)
    let l:level = 'error'
  endif

  if get(l:info, 'error', 0)
    call add(l:msgs, ' Errors: ' . l:info['error'])
  endif
  if get(l:info, 'warning', 0)
    call add(l:msgs, ' Warnings: ' . l:info['warning'])
  endif
  if get(l:info, 'information', 0)
    call add(l:msgs, ' Infos: ' . l:info['information'])
  endif
  if get(l:info, 'hint', 0)
    call add(l:msgs, ' Hints: ' . l:info['hint'])
  endif
  let l:msg = join(l:msgs, "\n")
  if empty(l:msg) | let l:msg = ' All OK' | endif
  call v:lua.require('coc-notify').coc_diag_notify(l:msg, l:level)
endfunction

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

if !lib#bundle#has_loaded('ultisnips')
  imap <C-a> <Plug>(coc-snippets-expand)
endif

if coc#util#api_version() <= 30
  inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
  inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
  inoremap <expr><CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
else
  let s:pumid = 0
  function! s:pum_next() abort
    let cur_pumid = coc#pum#winid()
    if s:pumid != cur_pumid
      let s:pumid = cur_pumid

      let input = getwinvar(cur_pumid, 'input', '')
      let index = coc#window#get_cursor(cur_pumid)[0] - 1
      let words = getwinvar(cur_pumid, 'words', [])
      let selword = get(words, index, '')
      if input != selword
        call coc#pum#next(0)
        return coc#pum#prev(1)
      else
        return coc#pum#next(1)
      endif
    else
      return coc#pum#next(1)
    endif
  endfunction

  inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? <SID>pum_next() :
      \ <SID>check_back_space() ? "\<Tab>" :
      \ coc#refresh()
  inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"
  inoremap <silent><expr> <c-space> coc#refresh()
  inoremap <silent><expr> <CR> coc#pum#visible() ? 
      \ coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

  hi CocSearch ctermfg=255 cterm=bold
  hi CocMenuSel ctermbg=109 ctermfg=239 cterm=bold
endif

nnoremap <silent> K :call <SID>show_documentation()<CR>

" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

nmap <silent> <space>ci :<C-U>CocDiagnostics<CR>
nmap <silent> <space>cn <Plug>(coc-diagnostic-next)
nmap <silent> <space>cp <Plug>(coc-diagnostic-prev)
nmap <silent> <space>cs :<C-U><C-R>=printf("CocSearch -w %s", expand('<cword>'))<CR><CR>
nmap <silent> <space>cl :<C-U>CocCommand workspace.showOutput coc-ext<CR>

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

vmap <silent> <leader>cn <Plug>(coc-ext-change-name-rule)

nmap <silent> <leader>cs <Plug>(coc-ext-cursor-symbol)

augroup my_coc_nvim
  autocmd!
  autocmd FileType python let b:coc_root_patterns = ['.env']

  autocmd BufEnter,BufRead *.encrypted set filetype=encrypted
  autocmd FileType encrypted setl nomodifiable buftype=nofile

  " autocmd User CocNvimInit call s:init_coc()
  " autocmd User CocStatusChange call s:status_notify()
  " autocmd User CocDiagnosticChange call s:diagnostic_notify()
augroup END

cnoreabbrev <expr> Cl ((getcmdtype() is# ':' && getcmdline() is# 'Cl') ?
    \ ('CocList') : ('Cl'))
