if exists('g:lib_bundle_ycm_load')
    if exists('g:loaded_youcompleteme')
        unlet g:loaded_youcompleteme
    endif
    exec 'so '.g:vimhome.'/conf/ycm.vim'
else
    let g:loaded_youcompleteme = 1
endif

" Some vim recording may has problem when exec VimMetaOpen
call lib#terminal#meta_mode(0)
command! -nargs=0 -bang VimMetaOpen call lib#terminal#meta_mode(<bang>0)
command! -nargs=0 -bang VimMetaClose call lib#terminal#meta_mode(<bang>1)

if has('cscope')
    command! -nargs=0 CscopeTags call lib#cscope#gen_tags()
endif

command! -nargs=0 YcmCursorMovedAutoCmdsToggle
            \ call lib#ycm#cursor_move_autocmds_toggle()

command! -nargs=0 GenTernProject
            \ call lib#javascript#tern_project()

command! -nargs=0 MyDebug
            \ call lib#debug#foo()
