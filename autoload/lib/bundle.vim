let s:all_valid_bundles = [
            \ 'DrawIt',
            \ 'LeaderF',
            \ 'ack.vim',
            \ 'ale',
            \ 'asyncrun.vim',
            \ 'gruvbox',
            \ 'jedi-vim',
            \ 'nerdtree',
            \ 'nord-vim',
            \ 'rainbow',
            \ 'supertab',
            \ 'syntastic',
            \ 'tabular',
            \ 'tagbar',
            \ 'twitvim',
            \ 'vim-airline',
            \ 'vim-commentary',
            \ 'vim-dirdiff',
            \ 'vim-dirvish',
            \ 'vim-erlang-tags',
            \ 'vim-fugitive',
            \ 'vim-gitgutter',
            \ 'vim-go',
            \ 'vim-gutentags',
            \ 'vim-javacomplete2',
            \ 'vim-markdown',
            \ 'vim-python-pep8-indent',
            \ 'vim-signature',
            \ 'vim-vue',
            \ 'vim-toml',
            \ 'vim-javascript',
            \ ]

let s:bundle_priority = {
            \ 'vim-maktaba': 1,
            \ 'vim-glaive': 1,
            \ 'gruvbox': -1
            \ }

let s:loaded_bundles = {}


function! s:priority_comp(i1, i2)
    function! s:get_priority(i)
        if has_key(s:bundle_priority, a:i)
            return s:bundle_priority[a:i]
        else
            return 0
        endif
    endfunc
    let a:p1 = s:get_priority(a:i1)
    let a:p2 = s:get_priority(a:i2)
    return a:p1 == a:p2 ? 0 : a:p1 < a:p2 ? 1 : -1
endfunc


function! lib#bundle#ycm()
    unlet g:loaded_youcompleteme
    exec 'so '.g:vimhome.'/ycm/ycm.vim'
endfunc


function! lib#bundle#load()
    if exists('g:lib_bundle_whitelist')
        let a:wlist = g:lib_bundle_whitelist
    else
        let a:wlist = s:all_valid_bundles
        " let a:wlist = []
        " for a:i in split(glob(g:vimhome.'/bundle/*'), '\n')
        "     let a:name=split(a:i, '/')[-1]
        "     call add(a:wlist, a:name)
        " endfor
    endif
    let a:bdict = {}
    if exists('g:lib_bundle_blacklist')
        for a:i in g:lib_bundle_blacklist
            let a:bdict[a:i] = 1
        endfor
    endif
    let a:lib_bundle_list = []
    for a:i in a:wlist
        if !has_key(a:bdict, a:i)
            call add(a:lib_bundle_list, a:i)
        endif
    endfor
    let a:lib_bundle_list = sort(a:lib_bundle_list, 's:priority_comp')

    let a:dir = g:vimhome.'/bundle'
    call plug#begin(a:dir)
    for a:i in a:lib_bundle_list
        Plug a:dir.'/'.a:i
    endfor
    call plug#end()

    let s:loaded_bundles = {}
    for a:i in a:lib_bundle_list
        let s:loaded_bundles[a:i] = 1
        let a:cfile=g:vimhome.'/conf/'.a:i.'.vim'
        if filereadable(a:cfile)
            exec 'so '.a:cfile
        endif
    endfor
    exec 'so '.g:vimhome.'/conf/others.vim'
endfunc


function! lib#bundle#has_loaded(name)
    return has_key(s:loaded_bundles, a:name)
endfunc
