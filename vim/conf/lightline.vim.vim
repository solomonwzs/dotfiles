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
        \       [ 'vsstatus' ],
        \   ],
        \ }

let g:lightline.inactive = {
        \   'left': [
        \       [ 'readonly', 'filename', 'modified' ],
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
        \       [ 'filepath', 'close' ],
        \   ],
        \ }

let g:lightline.tab = {
        \ 'active': [ 'tabnum', 'filename', 'modified' ],
        \ 'inactive': [ 'tabnum', 'filename', 'modified' ],
        \ }

let g:lightline.component_function = {
        \ }

let g:lightline.tab_component_function = {
        \   'modified' : 'LightlineTabModified',
        \ }

let g:lightline.component_expand = {
        \   'bufferline'  : 'lightline#bufferline#buffers',
        \   'coc_error'   : 'LightlineCocErrors',
        \   'coc_fix'     : 'LightlineCocFixes',
        \   'coc_hint'    : 'LightlineCocHints',
        \   'coc_info'    : 'LightlineCocInfos',
        \   'coc_warning' : 'LightlineCocWarnings',
        \   'cocstatus'   : 'coc#status',
        \   'filepath'    : 'LightLineFilePath',
        \   'vsstatus'    : 'LightlineVerCtrlStatus',
        \   'method'      : 'LightlineCocCurrentFunction',
        \   'modifiedx'   : 'LightlineModified',
        \   'readonly'    : 'LightlineReadonly',
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

let g:lightline.enable = {
        \   'tabline': 1,
        \ }

function! LightLineFilePath() abort
    let icon = lib#icons#file_node_ext_icon(&filetype, expand('%:t'), expand('%:e'))
    let icon = empty(icon) ? '' : icon.'  '
    return icon.expand('%')
endfunction

function! LightlineReadonly() abort
    return &readonly && &filetype !=# 'help' ? '' : ''
endfunction

function! LightlineModified() abort
    return &modified ? '' :
            \ &modifiable ? '' : '-'
endfunction

function! LightlineTabModified(n) abort
    let winnr = tabpagewinnr(a:n)
    return gettabwinvar(a:n, winnr, '&modified') ? '' :
            \ gettabwinvar(a:n, winnr, '&modifiable') ? '' : '-'
endfunction

function! LightlineBufferline() abort
    call bufferline#refresh_status()
    return [
            \ g:bufferline_status_info.before,
            \ g:bufferline_status_info.current,
            \ g:bufferline_status_info.after
            \ ]
endfunction

function s:git_status()
    let gitbranch = trim(get(g:, 'coc_git_status', ''))
    if empty(gitbranch) | return '' | endif

    let gitcount = trim(get(b:, 'coc_git_status', ''))
    if empty(gitcount)
        return printf('%s', gitbranch)
    else
        return printf('%s [%s]', gitbranch, gitcount)
    endif
endfunction

function s:svn_status()
    let svnstatus = lib#svn#status()
    if empty(svnstatus) | return '' | endif

    let svncount = lib#svn#count()
    if empty(svncount) || svncount ==# ' '
        return printf('%s', svnstatus)
    else
        return printf('%s [%s]', svnstatus, svncount)
    endif
endfunction

function! LightlineVerCtrlStatus() abort
    if winwidth(0) < 80
        return ''
    endif
    let status = s:git_status()
    if empty(status) | let status = s:svn_status() | endif
    return status
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
    let msg = s:lightline_coc_diagnostic('information', '')
    if empty(msg)
        let msg = s:lightline_ale_diagnostic('info', '')
    endif
    return msg
endfunction

function! LightlineCocHints() abort
    return s:lightline_coc_diagnostic('hints', '')
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
