" @author     Solomon Ng <solomon.wzs@gmail.com>
" @version    1.0
" @date       2019-04-04
" @license    GPL-2.0+

let g:lib_translate_target_lang = get(g:, 'lib_translate_target_lang', 'zh-CN')

function! lib#translate#google(text)
  if a:text ==# ''
    return
  endif

  let res = lib#py#call("translate", "google_translate",
      \ {"text": a:text, "tl": g:lib_translate_target_lang})
  if res.error == 0
    echo res.data
  endif
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

  let pys = g:vimhome.'/pythonx/VimExt/translate.py'
  let cmd = ['/usr/bin/python3', pys, '-t', g:lib_translate_target_lang, 
      \ a:text]
  call lib#async#async_call(cmd, {
      \ 'ok_cb': function('s:show_message'),
      \ 'err_cb': '_msg'
      \ })
endfunc
