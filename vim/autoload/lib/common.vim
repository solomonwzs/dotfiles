" @author     Solomon Ng <solomon.wzs@gmail.com>
" @version    1.0
" @date       2021-01-04
" @license    MIT

let s:editor = 'vim'
if has('nvim')
    let s:editor = 'nvim'
endif

" function lib#common#visual_selection()
"     if mode() ==? 'v'
"         let [line_start, column_start] = getpos('v')[1:2]
"         let [line_end, column_end] = getpos('.')[1:2]
"     else
"         let [line_start, column_start] = getpos("'<")[1:2]
"         let [line_end, column_end] = getpos("'>")[1:2]
"     end

"     if (line2byte(line_start) + column_start) > 
"             \ (line2byte(line_end) + column_end)
"         let [line_start, column_start, line_end, column_end] =
"                 \ [line_end, column_end, line_start, column_start]
"     end

"     let lines = getline(line_start, line_end)
"     if len(lines) == 0
"         return ''
"     endif

"     let lines[-1] = lines[-1][: column_end - 1]
"     let lines[0] = lines[0][column_start - 1:]
"     return join(lines, "\n")
" endfunc

function! lib#common#visual_selection(e)
    try
        let x_save = @x
        norm! gv"xy
        return a:e == 1 ? escape(@x, '"') : @x
    finally
        let @x = x_save
    endtry
endfunction

function! lib#common#strtrim(str, trim)
    return substitute(a:str, printf('%s$', a:trim), '', 'g')
endfunc

function! lib#common#editor()
    return s:editor
endfunc

function! lib#common#min(first, ...)
    let val = a:first
    for i in range(0, len(a:000) - 1)
        if a:000[i] < val
            let val = a:000[i]
        endif
    endfor
    return val
endfunction

function! lib#common#max(first, ...)
  let val = a:first
  for i in range(0, len(a:000) - 1)
    if a:000[i] > val
      let val = a:000[i]
    endif
  endfor
  return val
endfunction
