" @author     Solomon Ng <solomon.wzs@gmail.com>
" @version    1.0
" @date       2022-07-21
" @license    GPL-2.0+

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
  let res = lib#py#call("helper", "parse_filepath", a:line)
  let icon = lib#icons#file_node_ext_icon(res.data.ext, res.data.name)
  return icon.'  '.a:line
endfunction

" function! leaderf#rrg#files_with_matches_after_enter(orig_buf_nr, orig_cursor, args) abort
"   echo a:orig_buf_nr."\n"
" endfunction
