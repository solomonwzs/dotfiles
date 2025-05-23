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

hi CocListHeader ctermfg=16 ctermbg=108 cterm=bold guifg=#000000 guibg=#87af87 gui=bold

hi CocListSep0 ctermfg=108 ctermbg=167 guifg=#87af87 guibg=#d75f5f
hi CocListArgs ctermfg=16 ctermbg=167 cterm=bold guifg=#000000 guibg=#d75f5f

hi CocListSep1 ctermfg=167 ctermbg=241 guifg=#d75f5f guibg=#626262
hi CocListPath ctermfg=195 ctermbg=241 guifg=#d7ffff guibg=#626262

hi CocListSep2 ctermfg=241 ctermbg=237 guifg=#626262 guibg=#3a3a3a
hi CocListBg ctermbg=237 guibg=#3a3a3a
hi CocListSep3 ctermfg=195 ctermbg=237 guifg=#d7ffff guibg=#3a3a3a

hi CocListInfo ctermfg=16 ctermbg=195 guifg=#000000 guibg=#d7ffff
hi CocListSep4 ctermfg=149 ctermbg=195 guifg=#afd75f guibg=#d7ffff

hi CocListTotal ctermfg=16 ctermbg=149 guifg=#000000 guibg=#afd75f

" hi clear CocFloating
" hi CocFloating guibg=None
hi CocFloatingBorder ctermfg=243 guifg=#767676

hi CocPumSearch ctermfg=255 cterm=bold guifg=#eeeeee gui=bold
hi CocMenuSel ctermfg=239 ctermbg=109 cterm=bold guifg=#4e4e4e guibg=#87afaf gui=bold

let s:is_nvim = has('nvim')
let s:hide_pum = has('nvim-0.6.1') || has('patch-8.2.3389')
let s:is_vim = !s:is_nvim

let g:coc_disable_transparent_cursor = 1

" let g:coc_borderchars = ['─', '│', '─', '│', '╭', '╮', '╯', '╰']
let g:coc_borderchars = ['─', '│', '─', '│', '┌', '┐', '┘', '└']

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
    call add(l:msgs, '󰋼 Infos: ' . l:info['information'])
  endif
  if get(l:info, 'hint', 0)
    call add(l:msgs, '󰌵 Hints: ' . l:info['hint'])
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

function! s:insert_word(word) abort
  let cur_pumid = coc#pum#winid()
  let parts = getwinvar(cur_pumid, 'parts', [])
  if !empty(parts)
    let curr = getline('.')
    if curr ==# parts[0].a:word.parts[1]
      return
    endif
    if !exists('*nvim_buf_set_text')
      noa call setline('.', parts[0].a:word.parts[1])
      noa call cursor(line('.'), strlen(parts[0].a:word) + 1)
    else
      let row = line('.') - 1
      let startCol = strlen(parts[0])
      let endCol = strlen(getline('.')) - strlen(parts[1])
      call nvim_buf_set_text(bufnr('%'), row, startCol, row, endCol, [a:word])
      call cursor(line('.'), strlen(parts[0].a:word) + 1)
    endif
    doautocmd TextChangedP
  endif
endfunction
  
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
      call timer_start(10, {-> s:insert_word(selword)})
      return ''
    endif
  endif

  return coc#pum#next(1)
endfunction

function! s:pum_prev() abort
  return coc#pum#prev(1)
endfunction

" require coc-snippets
inoremap <silent><expr> <TAB>
    \ coc#pum#visible() ?
    \   <SID>pum_next() :
    \   coc#expandableOrJumpable() ?
    \     "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump', ''])\<CR>" :
    \     <SID>check_back_space() ?
    \       "\<TAB>" :
    \       coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? <SID>pum_prev() : "\<C-h>"
inoremap <silent><expr> <c-space> coc#refresh()
inoremap <silent><expr> <CR> coc#pum#visible() ? 
    \ coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

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

" for coc-git
nmap <silent> <space>cb :<C-U>CocCommand git.showBlameDoc<CR>

augroup my_coc_nvim
  autocmd!
  autocmd FileType python let b:coc_root_patterns = ['.env']

  autocmd BufEnter,BufRead *.encrypted set filetype=encrypted
  autocmd FileType encrypted setl nomodifiable buftype=nofile

  " autocmd User CocNvimInit call s:init_coc()
  " autocmd User CocStatusChange call s:status_notify()
  " autocmd User CocDiagnosticChange call s:diagnostic_notify()
augroup END

command! -nargs=* -complete=custom,coc#list#options CocListX
    \ :call coc#rpc#notify('openList', lib#py#call('shlex', 'split', <q-args>).data)

cnoreabbrev <expr> Cl ((getcmdtype() is# ':' && getcmdline() is# 'Cl') ?
    \ ('CocListX') : ('Cl'))

" for coc-ext-common
let s:coc_ext_conf = g:vimhome.'/conf/coc-ext.vim'
if filereadable(s:coc_ext_conf)
  exec 'so '.s:coc_ext_conf
endif

if s:is_nvim
  let s:coc_ext_lua = g:vimhome.'/lua/coc-ext.lua'
  if filereadable(s:coc_ext_lua)
    exec 'lua require("coc-ext")'
  endif
endif
