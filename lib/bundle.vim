function! lib#bundle#gen(dir, is_white_list, list)
    let a:edir=fnameescape(a:dir)
    silent exec '![ -d '.a:edir.' ] && rm -r '.a:edir
    silent exec '!mkdir '.a:edir

    if a:is_white_list == 0
        for a:bundle in split(glob(fnameescape(g:vimhome).'/bundle/*'), '\n')
            let a:symbolic = split(a:bundle, '/')[-1]
            silent exec '!ln -s '.a:bundle.' '.a:edir.'/'.a:symbolic
        endfor

        for a:bundle in a:list
            let a:bdir = a:edir.'/'.a:bundle
            if !empty(glob(a:bdir))
                silent exec '!rm '.a:bdir
            endif
        endfor
    else
        for a:bundle in a:list
            let a:name = split(a:bundle, '/')[-1]
            let a:ori = fnameescape(g:vimhome).'/bundle/'.a:name
            silent exec '!ln -s '.a:ori.' '.a:edir.'/'.a:name
        endfor
    end
endfunc


function! lib#bundle#load(dir)
    call plug#begin(a:dir)
    let a:edir = fnameescape(a:dir)
    for a:bundle in split(glob(a:edir.'/*'), '\n')
        Plug ''.a:bundle

        let a:name=split(a:bundle, '/')[-1]
        let a:cfile=fnameescape(g:vimhome).'/conf/'.a:name.'.vim'
        if filereadable(a:cfile)
            exec 'so '.a:cfile
        endif
    endfor
    call plug#end()
endfunc
