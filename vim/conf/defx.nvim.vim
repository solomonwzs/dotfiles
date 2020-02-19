scriptencoding utf-8

call defx#custom#option('_', {
        \ 'columns': 'indent:git:icon:filename',
        \ 'winwidth': 30,
        \ 'split': 'vertical',
        \ 'direction': 'topleft',
        \ 'listed': 1,
        \ 'show_ignored_files': 0,
        \ 'ignored_files':
        \     '.mypy_cache,.pytest_cache,.git,.hg,.svn,.stversions'
        \   . ',__pycache__,.sass-cache,*.egg-info,.DS_Store,*.pyc,*.swp'
        \ })

call defx#custom#column('mark', {
        \ 'readonly_icon': '',
        \ 'selected_icon': '',
        \ })

call defx#custom#column('icon', {
        \ 'directory_icon': '',
        \ 'opened_icon': '',
        \ 'root_icon': '≡',
        \ })

function! s:defx_mappings() abort
    nnoremap <silent><buffer><expr> <CR>
            \ defx#do_action('call', 'DefxSmart')
    nnoremap <silent><buffer><expr> C
            \ defx#do_action('cd', [defx#get_candidate()['action__path']])
    nnoremap <silent><buffer><expr> s
            \ defx#do_action('drop', 'vsplit')
    nnoremap <silent><buffer><expr> i
            \ defx#do_action('drop', 'split')
    nnoremap <silent><buffer><expr> t
            \ defx#do_action('drop', 'tabnew')
    nnoremap <silent><buffer><expr> I
            \ defx#do_action('toggle_ignored_files')

    nnoremap <silent><buffer><expr> R
            \ defx#do_action('redraw')
    nnoremap <silent><buffer><expr> c
            \ defx#do_action('copy')
    nnoremap <silent><buffer><expr> m
            \ defx#do_action('move')
    nnoremap <silent><buffer><expr> d
            \ defx#do_action('remove')
    nnoremap <silent><buffer><expr> p
            \ defx#do_action('paste')
    nnoremap <silent><buffer><expr> q
            \ defx#do_action('quit')
    nnoremap <silent><buffer><expr> yy
            \ defx#do_action('call', 'DefxYarkPath')
    nnoremap <silent><buffer><expr> <Left>
            \ defx#do_action('call', 'DefxEchoPath')
    nnoremap <silent><buffer><expr> <2-LeftMouse>
            \ defx#do_action('call', 'DefxSmart')
endfunction

function! DefxSmart(_)
    if line('.') ==# 1 || line('$') ==# 1
        return defx#call_action('cd', ['..'])
    endif

    if defx#is_directory()
        return defx#is_opened_tree() ?
                \ defx#call_action('close_tree') : defx#call_action('open_tree')
    else
        return defx#call_action('drop')
    endif
endfunction

function! DefxYarkPath(_) abort
    let candidate = defx#get_candidate()
    let @+ = candidate['action__path']
    echo 'yanked: ' . @+
endfunction

function! DefxEchoPath(_) abort
    let candidate = defx#get_candidate()
    echo candidate['action__path']
endfunction

augroup my_conf_defx_nvim
    autocmd!
    autocmd FileType defx call s:defx_mappings()
augroup END
