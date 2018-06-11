function! GenBundleFiles(dir, exclude)
    let a:edir=fnameescape(a:dir)
    silent exec '![ -d '.a:edir.' ] && rm -r '.a:edir
    silent exec '!mkdir '.a:edir
    for a:bundle in split(glob(fnameescape(g:vimhome).'/bundle/*'), '\n')
        let a:symbolic=split(a:bundle, '/')[-1]
        silent exec '!ln -s '.a:bundle.' '.a:edir.'/'.a:symbolic
    endfor

    for a:bundle in a:exclude
        let a:bdir=a:edir.'/'.a:bundle
        if !empty(glob(a:bdir))
            silent exec '!rm '.a:bdir
        endif
    endfor
endfunc


function! LoadBundle(dir)
    call plug#begin(a:dir)
    let a:edir=fnameescape(a:dir)
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
