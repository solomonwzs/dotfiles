" @author     Solomon Ng <solomon.wzs@gmail.com>
" @version    1.0
" @date       2022-07-24
" @license    MIT

function! leaderf#highlight#source(args) abort
  redir => tmp
  silent verbose highlight
  redir END
  let res = lib#py#call('helper', 'parse_highlight_info', tmp)
  return res.data
endfunction
