" @author     Solomon Ng <solomon.wzs@gmail.com>
" @version    1.0
" @date       2019-04-04
" @license    MIT

let g:lib_translate_target_lang = get(g:, 'lib_translate_target_lang', 'zh-CN')

function! lib#translate#google(text)
  if a:text ==# ''
    return
  endif

python3 << EOF
from translate import google
import urllib
import vim

text = vim.eval("a:text")
v = vim.vars

res = google.translate(text, v["lib_translate_target_lang"], 2)
if isinstance(res, str):
    print(res)
else:
    lines = []
    d = res.get("dict")
    if d is not None:
        for i in res.get("dict", []):
            pos = i.get("pos", "")
            term = ','.join(i.get("terms", []))
            lines.append(f"{pos}: {term}")
    else:
        for i in res.get("sentences", []):
            lines.append(i.get("trans"))
    trans = '\n'.join(lines)
    print(trans)
EOF
endfunc

function! s:show_message(data, ...)
  call ui#float#message('Google Translate', a:data, {})
  echo 'OK: '.join(a:data, '; ')
endfunc

function! lib#translate#google_async(text)
  echo 'translate ...'
  if a:text ==# ''
    return
  endif

  let pys = g:vimhome.'/pythonx/translate/google.py'
  let cmd = ['/usr/bin/python3', pys, '-t', g:lib_translate_target_lang, 
      \ a:text]
  call lib#async#async_call(cmd, {
      \ 'ok_cb': function('s:show_message'),
      \ 'err_cb': '_msg'
      \ })
endfunc
