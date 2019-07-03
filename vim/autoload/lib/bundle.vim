let s:basic_valid_bundles = [
        \ 'DrawIt',
        \ 'LeaderF',
        \ 'ack.vim',
        \ 'ale',
        \ 'asyncrun.vim',
        \ 'coc.nvim',
        \ 'deol.nvim',
        \ 'gruvbox',
        \ 'nerdtree',
        \ 'nord-vim',
        \ 'rainbow',
        \ 'tabular',
        \ 'tagbar',
        \ 'ultisnips',
        \ 'vim-airline',
        \ 'X:lightline.vim',
        \ 'vim-commentary',
        \ 'vim-delve',
        \ 'vim-dirdiff',
        \ 'vim-dirvish',
        \ 'vim-fugitive',
        \ 'vim-go',
        \ 'vim-gutentags',
        \ 'vim-markdown',
        \ 'vim-python-pep8-indent',
        \ 'vim-signature',
        \ 'vim-toml',
        \ 'vim-vue',
        \ 'vimproc.vim',
        \ ]

let s:bundle_priority = {
        \ 'vim-maktaba': 1,
        \ 'vim-glaive': 1,
        \ 'gruvbox': -1,
        \ }

let s:loaded_bundles = {}
let s:loaded_bundles_list = []


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

    let dir = g:vimhome.'/bundle'
    let s:loaded_bundles = {}
    call plug#begin(dir)
    for i in lib_bundle_list
        let plug = dir.'/'.i
        if !empty(glob(plug))
            call add(s:loaded_bundles_list, i)
            Plug plug
            let s:loaded_bundles[i] = 1
        endif
    endfor
    call plug#end()

    for i in s:loaded_bundles_list
        let cfile=g:vimhome.'/conf/'.i.'.vim'
        if filereadable(cfile)
            exec 'so '.cfile
        endif
    endfor
endfunc


function! lib#bundle#has_loaded(name)
    return has_key(s:loaded_bundles, a:name)
endfunc
