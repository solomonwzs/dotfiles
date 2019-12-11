function! lib#svn#status()
    if !executable('svn')
        return ''
    endif
    let dir = shellescape(expand('%:p:h'))
    let ver = trim(system('svn info --show-item=revision '.dir))
    if v:shell_error
        return ''
    endif

    let modified = 0
    let out = system('svn status '.dir)
    if empty(out) | let modified = 1 | endif
    if modified == 0
        return printf('svn *%d', ver)
    else
        return printf('svn %d', ver)
    endif
endfunc

function! lib#svn#count()
    if !executable('svn') || !executable('diffstat')
        return ''
    endif
    let fn = shellescape(expand('%'))
    let out = system('svn diff --diff-cmd diff '.fn.' | diffstat -t | awk -F, '.
            \ '''NR!=1{i+=$1;d+=$2;m+=$3}END{print i,d,m}''')
    let out = trim(out)
    if empty(out) | return ' ' | endif
    let cnt = split(out)
    let res = []
    if cnt[0] !=# '0' | call add(res, '+'.cnt[0]) | endif
    if cnt[1] !=# '0' | call add(res, '-'.cnt[1]) | endif
    if cnt[2] !=# '0' | call add(res, '~'.cnt[2]) | endif
    return trim(join(res, ' '))
endfunc
