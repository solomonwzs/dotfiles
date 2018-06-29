if has("cscope")
    set csprg=/usr/bin/cscope
    set csto=0
    set cst
    set nocsverb
    set csverb
endif
set cscopequickfix=s-,d-,c-,t-,e-,f-,i-

if !exists("g:lib_cscope_code_ext")
    let s:code_ext = ["c", "cc", "cpp", "h", "hpp"]
else
    let s:code_ext = g:lib_cscope_code_ext
end

if !exists("g:lib_cscope_dir")
    let s:workspace = fnameescape($HOME).'/.cache/tags-cscope'
else
    let s:workspace = g:lib_cscope_dir
end
silent exec '![ -d '.s:workspace.' ] || mkdir -p '.s:workspace


function! lib#cscope#basename()
    let a:cwd = getcwd()
    return join(split(a:cwd, "/"), "-")
endfunc


function! lib#cscope#gen_tags()
    let a:basename = lib#cscope#basename()
    let a:file_list = s:workspace."/".a:basename.".files"
    let a:names = []
    for a:ext in s:code_ext
        call add(a:names, '-iname "*.'.a:ext.'"')
    endfor
    let a:cmd = "!find . ".join(a:names, " -o ")." > ".a:file_list
    silent exec a:cmd

    let a:cscope_out = s:workspace."/".a:basename.".out"
    let a:cmd = "!cscope -bq -i ".a:file_list." -f ".a:cscope_out
    silent exec a:cmd

    if !exists("g:lib_cscope_added")
        silent exec ":cs add ".a:cscope_out
        let g:lib_cscope_added = 1
    end
    silent cs reset
    redraw!
    echo "reset cscope tags"
endfunc
command! -nargs=0 CscopeTags call lib#cscope#gen_tags()
