" @author     Solomon Ng <solomon.wzs@gmail.com>
" @version    1.0
" @date       2021-01-05
" @license    GPL-2.0+

function! lib#decode#decode_utf8_bytes()
  let text = lib#common#visual_selection(0)
  let res = lib#py#call('coder', 'decode_utf8_str', text)
  if res.error == 0
    call ui#float#message('UTF8 Decode', [res.data], {'visual': 1})
  else
    call ui#float#message('UTF8 Decode Error', [res.msg], {'visual': 1})
  endif
endfunc

function! lib#decode#decode_mime_str()
  let text = lib#common#visual_selection(0)
  let res = lib#py#call('coder', 'decode_mime_encode_str', text)
  if res.error == 0 && res.data[0] == 1
    call ui#float#message('Mime Decode', [res.data[1]], {'visual': 1})
  else
    call ui#float#message('Mime Decode Error', [res.data[1]], {'visual': 1})
  endif
endfunc
