" @author     Solomon Ng <solomon.wzs@gmail.com>
" @version    1.0
" @date       2021-01-05
" @license    MIT

let g:UltiSnipsExpandTrigger = '<C-a>'
let g:UltiSnipsJumpForwardTrigger = '<Tab>'
let g:UltiSnipsJumpBackwardTrigger = '<S-Tab>'

" vnoremap <silent> gc :call UltiSnips#SaveLastVisualSelection()<CR>gvs
"             \comment_line<C-r>=UltiSnips#ExpandSnippet()<CR>

vnoremap <silent> <leader>uf :call UltiSnips#SaveLastVisualSelection()<CR>gvs
    \file_type<C-r>=UltiSnips#ExpandSnippet()<CR>

" vnoremap <silent> <leader>uu :call UltiSnips#SaveLastVisualSelection()<CR>gvs
"     \encode_utf8<C-r>=UltiSnips#ExpandSnippet()<CR>

" vnoremap <silent> <leader>ug :call UltiSnips#SaveLastVisualSelection()<CR>gvs
"     \encode_gbk<C-r>=UltiSnips#ExpandSnippet()<CR>

vnoremap <silent> <leader>un :call UltiSnips#SaveLastVisualSelection()<CR>gvs
    \change_name_rule<C-r>=UltiSnips#ExpandSnippet()<CR>
