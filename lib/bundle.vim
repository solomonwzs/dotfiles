function! lib#bundle#ycm()
    unlet g:loaded_youcompleteme
    exec 'so '.g:vimhome.'/ycm/ycm.vim'
endfunc


function! lib#bundle#load()
    if exists("g:lib_bundle_whitelist")
        let a:wlist = []
        for a:i in g:lib_bundle_whitelist
            call add(a:wlist, g:vimhome.'/bundle/'.a:i)
        endfor
    else
        let a:wlist = split(glob(g:vimhome.'/bundle/*'), '\n')
    endif
    let a:blist = []
    if exists("g:lib_bundle_blacklist")
        for a:i in g:lib_bundle_blacklist
            call add(a:blist, g:vimhome.'/bundle/'.a:i)
        endfor
    endif
    let a:lib_bundle_list = []
    for a:i in a:wlist
        if index(a:blist, a:i) == -1
            call add(a:lib_bundle_list, a:i)
        endif
    endfor

    call plug#begin(g:vimhome.'/bundle')
    for a:i in a:lib_bundle_list
        Plug ''.a:i
    endfor
    call plug#end()

    let g:lib_bundle_loaded_list = []
    for a:i in a:lib_bundle_list
        let a:name=split(a:i, '/')[-1]
        call add(g:lib_bundle_loaded_list, a:name)
        let a:cfile=g:vimhome.'/conf/'.a:name.'.vim'
        if filereadable(a:cfile)
            exec 'so '.a:cfile
        endif
    endfor
    exec 'so '.g:vimhome.'/conf/others.vim'
endfunc


call lib#bundle#load()
if exists("g:lib_bundle_ycm_load")
    call lib#bundle#ycm()
endif
