scriptencoding utf-8

nmap <silent> <leader>t <Plug>(coc-ext-translate)
vmap <silent> <leader>t <Plug>(coc-ext-translate-v)

vmap <silent> <leader>du <Plug>(coc-ext-decode-utf8)
vmap <silent> <leader>dg <Plug>(coc-ext-decode-gbk)
vmap <silent> <leader>db <Plug>(coc-ext-decode-base64)

vmap <silent> <leader>eg <Plug>(coc-ext-encode-gbk)
vmap <silent> <leader>eu <Plug>(coc-ext-encode-utf8)

vmap <silent> <leader>dm <Plug>(coc-ext-decode-mime)

vmap <silent> <leader>cn <Plug>(coc-ext-change-name-rule)
nmap <silent> <leader>cs <Plug>(coc-ext-cursor-symbol)
vmap <silent> <leader>hl <Plug>(coc-ext-hl-preview)

vmap <C-c> <Plug>(coc-ext-copy-xclip)

" for kimi
nmap <silent> <leader>ch <Plug>(coc-ext-ai-chat-n)
vmap <silent> <leader>ch <Plug>(coc-ext-ai-chat-v)
augroup my_coc_nvim
  autocmd!
  autocmd FileType aichat nnoremap <buffer> K <Plug>(coc-ext-ai-show)
augroup END
