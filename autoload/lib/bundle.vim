let s:basic_valid_bundles = [
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
            \ 'rust.vim',
            \ 'tabular',
            \ 'tagbar',
            \ 'twitvim',
            \ 'ultisnips',
            \ 'vim-airline',
            \ 'vim-commentary',
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
            \ 'vim-startify',
            \ 'vim-vue',
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
    let a:p1 = s:get_priority(a:i1)
    let a:p2 = s:get_priority(a:i2)
    return a:p1 == a:p2 ? 0 : a:p1 < a:p2 ? 1 : -1
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
    let a:tmp_bundle_list = s:basic_valid_bundles
    if exists('g:lib_bundle_whitelist')
        let a:tmp_bundle_list += g:lib_bundle_whitelist
    endif
    let a:bdict = {}
    if exists('g:lib_bundle_blacklist')
        for a:i in g:lib_bundle_blacklist
            let a:bdict[a:i] = 1
        endfor
    endif
    let a:lib_bundle_list = []
    for a:i in a:tmp_bundle_list
        if !has_key(a:bdict, a:i)
            call add(a:lib_bundle_list, a:i)
        endif
    endfor
    let a:lib_bundle_list = sort(a:lib_bundle_list, 's:priority_comp')

    let g:loaded_youcompleteme = 1
    let a:dir = g:vimhome.'/bundle'
    call plug#begin(a:dir)
    for a:i in a:lib_bundle_list
        if a:i ==? 'ycm'
            if exists('g:loaded_youcompleteme')
                unlet g:loaded_youcompleteme
            endif
        else
            Plug a:dir.'/'.a:i
        endif
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
