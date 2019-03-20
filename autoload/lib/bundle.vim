let s:basic_valid_bundles = [
            \ 'DrawIt',
            \ 'LeaderF',
            \ 'ack.vim',
            \ 'ale',
            \ 'asyncrun.vim',
            \ 'deol.nvim',
            \ 'gruvbox',
            \ 'jedi-vim',
            \ 'nerdtree',
            \ 'nord-vim',
            \ 'rainbow',
            \ 'rust.vim',
            \ 'tabular',
            \ 'tagbar',
            \ 'ultisnips',
            \ 'vim-airline',
            \ 'vim-commentary',
            \ 'vim-delve',
            \ 'vim-dirdiff',
            \ 'vim-dirvish',
            \ 'vim-fugitive',
            \ 'vim-gitgutter',
            \ 'vim-go',
            \ 'vim-gutentags',
            \ 'vim-javacomplete2',
            \ 'vim-markdown',
            \ 'vim-python-pep8-indent',
            \ 'vim-racer',
            \ 'vim-signature',
            \ 'vim-toml',
            \ 'vim-vue',
            \ 'vimproc.vim',
            \ 'ycm',
            \ ]

let s:bundle_priority = {
            \ 'vim-maktaba': 1,
            \ 'vim-glaive': 1,
            \ 'gruvbox': -1,
            \ }

let s:loaded_bundles = {}
let s:group_bundle_list = []


function! s:priority_comp(i1, i2)
    function! s:get_priority(i)
        if has_key(s:bundle_priority, a:i)
            return s:bundle_priority[a:i]
        else
            return 0
        endif
    endfunc
    let p1 = s:get_priority(a:i1)
    let p2 = s:get_priority(a:i2)
    return p1 == p2 ? 0 : p1 < p2 ? 1 : -1
endfunc


function! s:update_bundle_group()
    let s:group_bundle_list = []

    if !exists('g:lib_code_completion') || g:lib_code_completion ==? 'ycm'
        call add(s:group_bundle_list, 'ycm')
    elseif g:lib_code_completion ==? 'supertab'
        call add(s:group_bundle_list, 'supertab')
    endif
endfunc


" function! lib#bundle#ycm()
"     if exists('g:loaded_youcompleteme')
"         unlet g:loaded_youcompleteme
"     endif
"     exec 'so '.g:vimhome.'/ycm/ycm.vim'
" endfunc


function! lib#bundle#load()
    let tmp_bundle_list = s:basic_valid_bundles
    if exists('g:lib_bundle_whitelist')
        let tmp_bundle_list += g:lib_bundle_whitelist
    endif
    let bdict = {}
    if exists('g:lib_bundle_blacklist')
        for i in g:lib_bundle_blacklist
            let bdict[i] = 1
        endfor
    endif
    let lib_bundle_list = []
    for i in tmp_bundle_list
        if !has_key(bdict, i)
            call add(lib_bundle_list, i)
        endif
    endfor
    let lib_bundle_list = sort(lib_bundle_list, 's:priority_comp')

    let g:loaded_youcompleteme = 1
    let dir = g:vimhome.'/bundle'
    call plug#begin(dir)
    for i in lib_bundle_list
        if i ==? 'ycm'
            if exists('g:loaded_youcompleteme')
                unlet g:loaded_youcompleteme
            endif
        else
            Plug dir.'/'.i
        endif
    endfor
    call plug#end()

    let s:loaded_bundles = {}
    for i in lib_bundle_list
        let s:loaded_bundles[i] = 1
        let cfile=g:vimhome.'/conf/'.i.'.vim'
        if filereadable(cfile)
            exec 'so '.cfile
        endif
    endfor
    exec 'so '.g:vimhome.'/conf/others.vim'
endfunc


function! lib#bundle#has_loaded(name)
    return has_key(s:loaded_bundles, a:name)
endfunc
