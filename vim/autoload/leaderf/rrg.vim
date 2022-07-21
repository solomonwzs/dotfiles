" @author     Solomon Ng <solomon.wzs@gmail.com>
" @version    1.0
" @date       2022-07-21
" @license    MIT

function! leaderf#rrg#files_with_matches_source(args) abort
  let out = system('rg '.a:args.pattern.' --files-with-matches --color never')
  return split(out)
endfunction

function! leaderf#rrg#files_with_matches_accept(line, args) abort
  let arr = split(a:line)
  exec 'silent edit '.arr[1]
  let @/ = a:args.pattern
  call feedkeys("/\<CR>")
endfunction

function! leaderf#rrg#files_with_matches_format_line(line, args) abort
python3 << EOF
import os
import vim

line = vim.eval("a:line")
fname = os.path.basename(line)
_, ext = os.path.splitext(line)
if len(ext) > 0:
  ext = ext[1:]

vim.command(f"let fname = '{fname}'")
vim.command(f"let ext = '{ext}'")
EOF
  let icon = lib#icons#file_node_ext_icon(ext, fname)
  return icon.'  '.a:line
endfunction

" function! leaderf#rrg#files_with_matches_after_enter(orig_buf_nr, orig_cursor, args) abort
"   echo a:orig_buf_nr."\n"
" endfunction
