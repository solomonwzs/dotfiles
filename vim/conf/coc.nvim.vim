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

call lib#color#theme_hl('CocListHeader', ['bg0_s', 'blue', 'bold'])

call lib#color#theme_hl('CocListSep0', ['blue', 'light_red', ''])
call lib#color#theme_hl('CocListArgs', ['bg0_s', 'light_red', 'bold'])

call lib#color#theme_hl('CocListSep1', ['light_red', 'bg3', 'bold'])
call lib#color#theme_hl('CocListPath', ['fg2', 'bg3', ''])

call lib#color#theme_hl('CocListSep2', ['bg3', 'bg1', ''])
call lib#color#theme_hl('CocListBg', ['', 'bg1', ''])
call lib#color#theme_hl('CocListSep3', ['light_blue', 'bg1', ''])

call lib#color#theme_hl('CocListInfo', ['bg0_s', 'light_blue', ''])
call lib#color#theme_hl('CocListSep4', ['light_green', 'light_blue', ''])

call lib#color#theme_hl('CocListTotal', ['bg0_s', 'light_green', ''])

" hi clear CocFloating
" hi CocFloating guibg=None
call lib#color#theme_hl('CocFloatingBorder', ['bg4', '', ''])

call lib#color#theme_hl('CocPumSearch', ['blue', '', ''])
call lib#color#theme_hl('CocMenuSel', ['bg0_s', 'light_blue', 'bold'])

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
