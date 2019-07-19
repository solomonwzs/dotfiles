let g:UltiSnipsExpandTrigger = '<C-a>'
let g:UltiSnipsJumpForwardTrigger = '<Tab>'
let g:UltiSnipsJumpBackwardTrigger = '<S-Tab>'

" vnoremap <silent> gc :call UltiSnips#SaveLastVisualSelection()<CR>gvs
"             \comment_line<C-r>=UltiSnips#ExpandSnippet()<CR>

vnoremap <silent> <leader>ft :call UltiSnips#SaveLastVisualSelection()<CR>gvs
        \file_type<C-r>=UltiSnips#ExpandSnippet()<CR>

vnoremap <silent> <leader>uu :call UltiSnips#SaveLastVisualSelection()<CR>gvs
        \encode_utf8<C-r>=UltiSnips#ExpandSnippet()<CR><esc>

vnoremap <silent> <leader>ug :call UltiSnips#SaveLastVisualSelection()<CR>gvs
        \encode_gbk<C-r>=UltiSnips#ExpandSnippet()<CR><esc>
