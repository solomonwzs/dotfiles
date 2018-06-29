let s:cursor_move_autocmds = 1
function! lib#ycm#cursor_move_autocmds_toggle()
    if s:cursor_move_autocmds == 1
        let s:cursor_move_autocmds = 0
        call youcompleteme#DisableCursorMovedAutocommands()
    else
        let s:cursor_move_autocmds = 1
        call youcompleteme#EnableCursorMovedAutocommands()
    endif
endfunc
command! -nargs=0 YcmCursorMovedAutoCmdsToggle
            \ call lib#ycm#cursor_move_autocmds_toggle()
