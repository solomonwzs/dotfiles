let g:UltiSnipsExpandTrigger = '<C-a>'
let g:UltiSnipsJumpForwardTrigger = '<Tab>'
let g:UltiSnipsJumpBackwardTrigger = '<S-Tab>'

vnoremap <silent> gc :call UltiSnips#SaveLastVisualSelection()<CR>gvs
            \comment_line<C-r>=UltiSnips#ExpandSnippet()<CR>

vnoremap <silent> ft :call UltiSnips#SaveLastVisualSelection()<CR>gvs
            \file_type<C-r>=UltiSnips#ExpandSnippet()<CR>
