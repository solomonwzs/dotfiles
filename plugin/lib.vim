if exists('g:lib_bundle_ycm_load')
    call lib#bundle#ycm()
endif

" Some vim recording may has problem when exec VimMetaOpen
call lib#terminal#meta_mode(0)
command! -nargs=0 -bang VimMetaOpen call lib#terminal#meta_mode(<bang>0)
command! -nargs=0 -bang VimMetaClose call lib#terminal#meta_mode(<bang>1)

if has('cscope')
    command! -nargs=0 CscopeTags call lib#cscope#gen_tags()
endif
