" @author     Solomon Ng <solomon.wzs@gmail.com>
" @version    1.0
" @date       2019-07-19
" @license    GPL-2.0+

let s:win_list = []

function! s:f_floatit(msg) dict
  let self.m_buf = nvim_create_buf(v:false, v:false)
  call nvim_buf_set_lines(self.m_buf, 0, -1, v:true, [a:msg])
  let self.m_win = nvim_open_win(self.m_buf, 0, {
          \ 'width': 7,
          \ 'height': 3,
          \ 'col': 1,
          \ 'row': 1,
          \ 'relative': 'cursor',
          \ })

  call nvim_win_set_option(self.m_win, 'number', v:false)
  call nvim_win_set_option(self.m_win, 'cursorline', v:false)

  call nvim_buf_set_option(self.m_buf, 'buftype', 'nofile')
  call nvim_buf_set_option(self.m_buf, 'bufhidden', 'wipe')
  call nvim_buf_set_option(self.m_buf, 'modified', v:false)
  call nvim_buf_set_option(self.m_buf, 'buflisted', v:false)

  execute 'augroup floatingw_' . self.m_win
  execute 'autocmd CursorMoved * echo 1'
  execute 'augroup END'
endfunction

" augroup xxx
"     autocmd CursorMoved 
" augroup END

function! s:f_closeit() dict
  echo 1
  if self.m_win != -1
    call nvim_win_close(self.m_win, v:true)
  endif
endfunction

function! ui#floatingw#new(arg)
  let nr = winnr()
  let instance = {
          \ 'm_win': -1,
          \ 'm_winnr': nr,
          \ 'm_winw': winwidth(nr),
          \ 'm_winh': winheight(nr),
          \ 'f_floatit': function('s:f_floatit'),
          \ 'f_closeit': function('s:f_closeit'),
          \ }
  return instance
endfunction

function! ui#floatingw#test()
  let obj = ui#floatingw#new({})
  call obj.f_floatit('Set the position, size, etc. of the floating window.')
endfunction
