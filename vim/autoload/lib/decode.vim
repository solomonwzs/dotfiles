" @author     Solomon Ng <solomon.wzs@gmail.com>
" @version    1.0
" @date       2021-01-05
" @license    MIT

function! lib#decode#decode_utf8_bytes()
  let text = lib#common#visual_selection(0)
  let ustr = ''
  let ok = v:true
python3 << EOF
import vim
import common

ok, ustr = common.decode_utf8_str(vim.eval('text'))
vim.command('let ustr = "%s"' % ustr)
if not ok:
  vim.command('let ok = v:false')
EOF
  if ok
    call ui#float#message('UTF8 Decode', [ustr], {'visual': 1})
  else
    call ui#float#message('UTF8 Decode Error', [ustr], {'visual': 1})
  endif
endfunc

function! lib#decode#decode_mime_str()
  let text = lib#common#visual_selection(0)
  let ustr = ''
  let ok = v:true
python3 << EOF
import vim
import common

ok, ustr = common.decode_mime_encode_str(vim.eval('text'))
vim.command('let ustr = "%s"' % ustr)
if not ok:
  vim.command('let ok = v:false')
EOF
  if ok
    call ui#float#message('Mime Decode', [ustr], {'visual': 1})
  else
    call ui#float#message('Mime Decode Error', [ustr], {'visual': 1})
  endif
endfunc
