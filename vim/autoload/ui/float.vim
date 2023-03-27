" @author     Solomon Ng <solomon.wzs@gmail.com>
" @version    1.0
" @date       2020-12-31
" @license    GPL-2.0+

let s:is_vim = !has('nvim')
let s:float_supported = exists('*nvim_open_win') || has('patch-8.1.1719')
let s:windows_list = []
let s:visual = 0

function! s:f_close() dict
  if self.m_win != -1
    if s:is_vim
      call popup_close(self.m_win)
    else
      call nvim_win_close(self.m_win, v:true)
    endif
  endif
  if self.m_buf != -1
    silent! bd! self.m_buf
  endif
endfunction

function! s:create_buf(text)
  if s:is_vim
    noautocmd let buf = bufadd('')
    noautocmd call bufload(buf)
    call setbufvar(buf, '&buflisted', 0)
    call deletebufline(buf, 1, '$')
    call setbufline(buf, 1, a:text)
  else
    let buf = nvim_create_buf(v:false, v:true)
    call nvim_buf_set_lines(buf, 0, -1, v:true, a:text)
  endif
  return buf
endfunction

function! s:text_area_size(text)
  let width = lib#common#min(60, &columns - 1)
  let height = 0
  let line_width = 0
  for i in range(0, len(a:text) - 1)
    let str_width = strwidth(a:text[i])
    if str_width > line_width
      let line_width = str_width
    endif
    let line = 1
    if str_width > width
      let line = str_width / width
      if str_width % width != 0
        let line += 1
      endif
    endif
    let height += line
  endfor
  return [lib#common#min(width, line_width), height]
endfunction

function! ui#float#new(title, content)
  let text = ['['.a:title.']', ''] + a:content
  let area_size = s:text_area_size(text)
  let buf = s:create_buf(text)
  if s:is_vim
    let win = popup_create(buf, {
        \ 'maxwidth': area_size[0] + 2,
        \ 'padding': [0, 1, 0, 1],
        \ 'col': 'cursor',
        \ 'line': 'cursor+1',
        \ })
  else
    let win = nvim_open_win(buf, v:false, {
        \ 'width': area_size[0] + 2,
        \ 'height': area_size[1],
        \ 'col': 0,
        \ 'row': 1,
        \ 'relative': 'cursor',
        \ })
  endif
  call setbufvar(buf, '&filetype', 'ui_float')
  return {'m_buf': buf, 'm_win': win, 'f_close': function('s:f_close')}
endfunction

function! ui#float#test()
  call ui#float#message('vim', ['hello world', 'just for test'])
  " call ui#float#message('vim', [a:text], {'visual': 1})
endfunction

function! ui#float#message(title, content, opts)
  if get(a:opts, 'visual', 0) == 1
    let s:visual = 1
  endif
  let obj = ui#float#new(a:title, a:content)
  call add(s:windows_list, obj)
endfunction

function! ui#float#close_all_float()
  if s:visual == 1
    let s:visual = 0
  else
    while !empty(s:windows_list)
      call s:windows_list[0].f_close()
      call remove(s:windows_list, 0)
    endwhile
  endif
endfunction

augroup my_autoload_ui_float
  autocmd CursorMoved * call ui#float#close_all_float()

  autocmd FileType ui_float setlocal nonumber
  autocmd FileType ui_float setlocal nocursorline
  autocmd FileType ui_float setlocal buftype=nofile
  autocmd FileType ui_float setlocal bufhidden=wipe
  autocmd FileType ui_float setlocal nomodified
  autocmd FileType ui_float setlocal nobuflisted
  if !s:is_vim
    autocmd FileType ui_float setlocal foldcolumn=1
    autocmd FileType ui_float
      \ setlocal winhl=Normal:Pmenu,NormalNC:Pmenu,FoldColumn:Pmenu
    " there is a single space after '\ '
    autocmd FileType ui_float setlocal fillchars=eob:\ 
  endif
augroup END
