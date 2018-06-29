function! lib#bundle#ycm()
    unlet g:loaded_youcompleteme
    exec 'so '.g:vimhome.'/ycm/ycm.vim'
endfunc


function! lib#bundle#load()
    if exists('g:lib_bundle_whitelist')
        let a:wlist = g:lib_bundle_whitelist
    else
        let a:wlist = []
        for a:i in split(glob(g:vimhome.'/bundle/*'), '\n')
            let a:name=split(a:i, '/')[-1]
            call add(a:wlist, a:name)
        endfor
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

    let a:dir = g:vimhome.'/bundle'
    call plug#begin(a:dir)
    for a:i in a:lib_bundle_list
        Plug a:dir.'/'.a:i
    endfor
    call plug#end()

    let g:lib_bundle_loaded_list = []
    for a:i in a:lib_bundle_list
        call add(g:lib_bundle_loaded_list, a:name)
        let a:cfile=g:vimhome.'/conf/'.a:i.'.vim'
        if filereadable(a:cfile)
            exec 'so '.a:cfile
        endif
    endfor
    exec 'so '.g:vimhome.'/conf/others.vim'
endfunc


call lib#bundle#load()
if exists('g:lib_bundle_ycm_load')
    call lib#bundle#ycm()
endif
