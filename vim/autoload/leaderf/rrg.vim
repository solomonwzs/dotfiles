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
  exec 'hide edit +/'.a:args.pattern.' '.arr[1]
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
