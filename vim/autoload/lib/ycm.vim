" @author     Solomon Ng <solomon.wzs@gmail.com>
" @version    1.0
" @date       2021-01-04
" @license    GPL-2.0+

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
