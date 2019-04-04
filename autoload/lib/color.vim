function! lib#color#vim_cterm_fg()
    let i = 0
    let prefix = 'xCterm_FG_'

    let groups = []
    while i < 256
        let group_name = prefix.i
        exec 'hi '.group_name.' ctermfg='.i
        exec 'syn match '.group_name.' contained "'.i.'"'
        call add(groups, group_name)
        let i += 1
    endwhile
    call add(groups, 'vimHiNmbr')

    let cluster_name = prefix.'Groups'
    exec 'syn match vimHiTerm contained "\cctermfg="he=e-1 nextgroup=@'.cluster_name
    exec 'syn cluster '.cluster_name.' contains='.join(groups, ',')
endfunc


function! lib#color#vim_cterm_bg()
    let i = 0
    let prefix = 'xCterm_BG_'

    let groups = []
    while i < 256
        let group_name = prefix.i
        exec 'hi '.group_name.' ctermfg=NONE ctermbg='.i
        exec 'syn match '.group_name.' contained "'.i.'"'
        call add(groups, group_name)
        let i += 1
    endwhile
    call add(groups, 'vimHiNmbr')

    let cluster_name = prefix.'Groups'
    exec 'syn match vimHiTerm contained "\cctermbg="he=e-1 nextgroup=@'.cluster_name
    exec 'syn cluster '.cluster_name.' contains='.join(groups, ',')
endfunc
