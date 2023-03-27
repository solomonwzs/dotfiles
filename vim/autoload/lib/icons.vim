" @author     Solomon Ng <solomon.wzs@gmail.com>
" @version    1.0
" @date       2021-01-04
" @license    GPL-2.0+

scriptencoding utf-8

function! lib#icons#file_node_ext_icon(filetype, filename)
  if g:loaded_defx_icons == 0 | return '' | endif

  let defx_icons = defx_icons#get()
  let icon = get(defx_icons.icons.exact_matches, tolower(a:filename), '')
  if !empty(icon) | return icon.icon | endif
  let icon = get(defx_icons.icons.extensions, tolower(a:filetype), '')
  if !empty(icon) | return icon.icon | else | return '' | endif
endfunction
