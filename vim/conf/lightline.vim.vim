scriptencoding utf-8

set showtabline=2
let s:coc_ok = 0

let g:lightline = {}
let g:lightline.active = {
        \   'left': [
        \       [ 'mode', 'paste' ],
        \       [ 'readonly', 'filename', 'modifiedx' ],
        \       [ 'method' ],
        \   ],
        \   'right':[
        \       [ 'coc_error', 'coc_warning', 'coc_hint', 'coc_info' ],
        \       [ 'filetype', 'fileencoding', 'lineinfo', 'percent' ],
        \       [ 'gitstatus' ],
        \   ],
        \ }

let g:lightline.inactive = {
        \   'left': [
        \       [ 'readonly', 'filename', 'modifiedx' ],
        \   ],
        \   'right':[
        \       [ 'filetype', 'fileencoding', 'lineinfo', 'percent' ],
        \   ],
        \ }

let g:lightline.tabline = {
        \   'left': [
        \       [ 'tabs' ],
        \   ],
        \   'right': [
        \       [ 'close' ],
        \   ],
        \ }

let g:lightline.tab = {
        \ 'active': [ 'tabnum', 'filename', 'modified' ],
        \ 'inactive': [ 'tabnum', 'filename', 'modified' ],
        \ }

let g:lightline.component_function = {
        \ }

let g:lightline.component_expand = {
        \   'coc_error'   : 'LightlineCocErrors',
        \   'coc_fix'     : 'LightlineCocFixes',
        \   'coc_hint'    : 'LightlineCocHints',
        \   'coc_info'    : 'LightlineCocInfos',
        \   'coc_warning' : 'LightlineCocWarnings',
        \   'cocstatus'   : 'coc#status',
        \   'gitstatus'   : 'LightlineGitStatus',
        \   'method'      : 'LightlineCocCurrentFunction',
        \   'modifiedx'   : 'LightlineModified',
        \   'readonly'    : 'LightlineReadonly',
        \   'bufferline'  : 'lightline#bufferline#buffers',
        \ }

let g:lightline.component_type = {
        \   'coc_error'   : 'error',
        \   'coc_warning' : 'warning',
        \   'coc_info'    : 'tabsel',
        \   'coc_hint'    : 'middle',
        \   'coc_fix'     : 'middle',
        \ }

let g:lightline.colorscheme = 'gruvbox'
let g:lightline.separator = { 'left': '', 'right': '' }

function! LightlineReadonly()
    return &readonly && &filetype !=# 'help' ? '' : ''
endfunction

function! LightlineModified()
    return &modified ? '' :
            \ &modifiable ? '' : '-'
endfunction

function! LightlineBufferline() abort
    call bufferline#refresh_status()
    return [
            \ g:bufferline_status_info.before,
            \ g:bufferline_status_info.current,
            \ g:bufferline_status_info.after
            \ ]
endfunction

function! LightlineGitStatus() abort
    if winwidth(0) < 120
        return ''
    endif
    let gitbranch = trim(get(g:, 'coc_git_status', ''))
    if empty(gitbranch)
        return ''
    endif

    let gitcount = trim(get(b:, 'coc_git_status', ''))
    return printf('%s [%s]', gitbranch, gitcount)
endfunction

function! s:lightline_coc_diagnostic(kind, sign) abort
    let info = get(b:, 'coc_diagnostic_info', 0)
    if empty(info) || get(info, a:kind, 0) == 0
        return ''
    endif
    return printf('%s %d', a:sign, info[a:kind])
endfunction

function! s:lightline_ale_diagnostic(kind, sign) abort
    let info = ale#statusline#Count(bufnr(''))
    if empty(info) || get(info, a:kind, 0) == 0
        return ''
    endif
    return printf('%s %d', a:sign, info[a:kind])
endfunction

function! LightlineCocErrors() abort
    let msg = s:lightline_coc_diagnostic('error', '✖')
    if empty(msg)
        let msg = s:lightline_ale_diagnostic('error', '✖')
    endif
    return msg
endfunction

function! LightlineCocWarnings() abort
    let msg = s:lightline_coc_diagnostic('warning', '⚠')
    if empty(msg)
        let msg = s:lightline_ale_diagnostic('warning', '⚠')
    endif
    return msg
endfunction

function! LightlineCocInfos() abort
    let msg = s:lightline_coc_diagnostic('information', '')
    if empty(msg)
        let msg = s:lightline_ale_diagnostic('info', '')
    endif
    return msg
endfunction

function! LightlineCocHints() abort
    return s:lightline_coc_diagnostic('hints', '!')
endfunction

function! LightlineCocCurrentFunction()
    return get(b:, 'coc_current_function', '')
endfunction

augroup my_conf_lightline_vim
    autocmd!

    autocmd CursorHold *  call lightline#update()
    autocmd CursorHoldI * call lightline#update()

    autocmd User CocDiagnosticChange call lightline#update()
    autocmd User ALEJobStarted       call lightline#update()
    autocmd User ALELintPost         call lightline#update()
    autocmd User ALEFixPost          call lightline#update()
augroup END
